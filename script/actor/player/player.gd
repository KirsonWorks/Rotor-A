class_name Player
extends Actor

signal died()

const RESPAWN_BLINK_TIME = 2500

@export var MOUSE_SENSITIVITY: float = 0.04
@export var MOTION_LIMIT: float = 30.0
@export var MOTION_SPEED: float = 3.0
@export var ROLL_FACTOR: float = 90.0

@export_category("Bound Zone")
@export var BOUND_LEFT: float = -75.0
@export var BOUND_RIGHT: float = 75.0
@export var BOUND_FRONT: float = -15.0
@export var BOUND_BACK: float = 50.0

var primary_weapon_specs_index: int:
	get:
		return primary_weapon_specs_index
	set(value):
		primary_weapon_specs_index = clamp(value, 0, len(_weapon_specs_map) - 1)
		var specs = _weapon_specs_map[primary_weapon_specs_index]
		_primary_weapon = specs.get_weapon()
		_primary_weapon.use_specs(specs)
		
var _target_position = Vector3.ZERO
var _weapon_specs_map: Array[WeaponSpecs]
var _primary_weapon: WeaponBase
var _secondary_weapon: WeaponBase
var _is_alive: bool
var _health_max: float
var _respawn_time: int
 
func respawn() -> void:
	position = Vector3.ZERO
	HEALTH = _health_max
	_is_alive = true
	_target_position = position
	_respawn_time = Time.get_ticks_msec()
	show()

func upgrade() -> void:
	primary_weapon_specs_index += 1

func add_health(value: float) -> void:
	super.add_health(value)
	
	if is_zero_approx(HEALTH):
		hide()
		_is_alive = false
		Global.create_explosion(global_position)
		died.emit()

func can_collide() -> bool:
	return _is_alive and \
		Time.get_ticks_msec() - _respawn_time > RESPAWN_BLINK_TIME and \
		super.can_collide()

func _ready() -> void:
	for specs in find_children("*", "WeaponSpecs"):
		_weapon_specs_map.push_back(specs)
	
	_weapon_specs_map.sort_custom(
		func(a: WeaponSpecs, b: WeaponSpecs):
			return a.UPGRADE_INDEX < b.UPGRADE_INDEX)
	
	primary_weapon_specs_index = 0
	
	_health_max = HEALTH
	health_changed.emit(HEALTH)
	respawn()
	
func _input(event: InputEvent) -> void:
	if _is_alive and \
		Input.mouse_mode == Input.MOUSE_MODE_CAPTURED and \
		event is InputEventMouseMotion:
			var motion_event = event as InputEventMouseMotion
			var limit = Vector2(MOTION_LIMIT, MOTION_LIMIT)
			var relative = motion_event.relative.clamp(-limit, limit)
			var offset = Vector3(relative.x, 0.0, relative.y) * MOUSE_SENSITIVITY
			
			_add_target_position(offset)
	
func _process(delta: float) -> void:
	if _is_alive:
		var roll = (position - _target_position) / ROLL_FACTOR
		rotation.x = -roll.z
		rotation.z = roll.x
		position = position.lerp(_target_position, MOTION_SPEED * delta)
		
		if Input.is_action_pressed("primary_weapon") and _primary_weapon:
			_primary_weapon.shot()
			
		if Input.is_action_pressed("secondary_weapon") and _secondary_weapon:
			_secondary_weapon.shot()

func _add_target_position(value: Vector3) -> void:
	_target_position += value
	_target_position.x = clamp(_target_position.x, BOUND_LEFT, BOUND_RIGHT)
	_target_position.z = clamp(_target_position.z, BOUND_FRONT, BOUND_BACK)
