class_name EnemyBase
extends Actor

@export_node_path("Actor") var TARGET_PATH
@export_node_path("WeaponBase") var WEAPON_PATH
@export var FOLLOW_TO_CAMERA: bool = false
@onready var target: Actor = get_node_or_null(TARGET_PATH) if TARGET_PATH else null
@onready var weapon: WeaponBase = get_node_or_null(WEAPON_PATH) if WEAPON_PATH else null

enum EnemyState {NONE, IDLE, RECON, COMBAT, DEATH}

var _state = EnemyState.NONE

func set_target(value: Actor) -> void:
	target = value
	TARGET_PATH = get_path_to(target)

func add_health(value: float) -> void:
	super.add_health(value)
	
	if is_zero_approx(HEALTH):
		change_state(EnemyState.DEATH)

func change_state(new_state: EnemyState) -> void:
	if _state == new_state:
		return
	
	if new_state == EnemyState.DEATH:
		death()
	
	_state = new_state

func death() -> void:
	pass

func idle_process(_delta: float) -> void:
	var distance_to_camera = Global.camera.global_position.z - global_position.z

	if distance_to_camera <= Global.camera.far:
		change_state(EnemyState.RECON)

func recon_process(_delta: float) -> void:
	pass

func combat_process(_delta: float) -> void:
	pass

func death_process(_delta: float) -> void:
	pass

func angle_distance(from, to):
	var diff = fmod(to - from, TAU)
	return fmod(diff * 2.0, TAU) - diff
	
func _ready() -> void:
	change_state(EnemyState.IDLE)

func _process(delta: float) -> void:
	if _state != EnemyState.NONE and \
		global_position.z > Global.camera.global_position.z:
		change_state(EnemyState.NONE)
	
	match _state:
		EnemyState.IDLE:
			idle_process(delta)
		EnemyState.RECON:
			recon_process(delta)
		EnemyState.COMBAT:
			combat_process(delta)
		EnemyState.DEATH:
			death_process(delta)

	if FOLLOW_TO_CAMERA:
		global_position += Global.camera_velocity * delta
