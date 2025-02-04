class_name EnemyCopter
extends EnemyBase

@export var SPEED: float = 30.0
@export var DEVIATION: Vector3
@export var COMBAT_DISTANCE: float = 80.0
@export var COLLISION_DAMAGE: float = 75.0
@export var AIM_SIZE: float = 5.0

var _time: float = 0.0
var _combat_distance: float

func _ready() -> void:
	super._ready()
	var d = COMBAT_DISTANCE * 0.1
	_combat_distance = COMBAT_DISTANCE - randf_range(-d, d)

func death() -> void:
	Global.create_explosion(global_position)
	queue_free()

func recon_process(delta: float) -> void:
	var z = SPEED * delta
	global_translate(Vector3.BACK * z)
	rotation.x = z
	
	if abs(global_position.z - target.global_position.z) <= _combat_distance:
		FOLLOW_TO_CAMERA = true
		change_state(EnemyState.COMBAT)

func combat_process(delta: float) -> void:
	_time += delta
	
	var speed = SPEED * delta
	var is_target_visible = target.is_visible_in_tree() if target else false
	var lerp_x = lerp(global_position.x, target.global_position.x, 1.0 * delta) \
		if is_target_visible else global_position.x
	
	lerp_x = clamp(lerp_x, global_position.x - speed, global_position.x + speed)
	var x = sin(_time) * DEVIATION.x * delta + lerp_x
	var roll = (global_position.x - x) / 2.0
	var z = cos(_time) * DEVIATION.z * delta
	var y = cos(_time) * DEVIATION.y * delta
	
	rotation.z = roll
	rotation.x = z
	global_position.x = x
	global_position.y += y
	global_position.z += z
	
	if weapon and target and target.can_collide():
		if abs(global_position.x - target.global_position.x) <= AIM_SIZE:
			weapon.shot()

func _physics_process(_delta: float) -> void:
	var result = CollisionManager.check_collision(self)
	
	if result:
		result.add_damage(COLLISION_DAMAGE)
		death()
