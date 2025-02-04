class_name EnemyCannon
extends EnemyBase

@export var COMBAT_DISTANCE: float = 150.0
@export_node_path("VisualInstance3D") var GUN_PATH: NodePath
@export_node_path("VisualInstance3D") var GUN_SUPPORT_PATH: NodePath
@onready var gun: Node3D = get_node_or_null(GUN_PATH) if GUN_PATH else null
@onready var gun_support: Node3D = get_node_or_null(GUN_SUPPORT_PATH) \
	if GUN_SUPPORT_PATH else null

var _target_angle: float = 0.0

func death() -> void:
	Global.create_explosion(global_position)
	queue_free()

func recon_process(_delta: float) -> void:
	change_state(EnemyState.COMBAT)

func combat_process(delta: float) -> void:
	if target:
		var diff = (Vector2(target.global_position.x, target.global_position.z) - \
			Vector2(global_position.x, global_position.z)).normalized()
		_target_angle = fmod(diff.angle(), TAU)
	
	if gun_support:
		var angle = -gun_support.global_rotation.y - PI / 2
		var angle_dist = angle_distance(angle, _target_angle)
		var angle_step = 0.2 * delta * sign(angle_dist)
		
		angle += angle_step
		gun_support.global_rotation.y += -angle_step
	
		if abs(angle_dist) < 0.2 and target and \
			abs(global_position.z - target.global_position.z) < COMBAT_DISTANCE:
			weapon.shot()
