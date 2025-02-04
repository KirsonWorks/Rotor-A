class_name EnemyPlane
extends EnemyBase

@export var SPEED: float = 10.0
@export var COLLISION_DAMAGE: float = 20.0

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

	var angle = -rotation.y - PI / 2
	var angle_dist = angle_distance(angle, _target_angle)
	var angle_step = 0.2 * delta * sign(angle_dist)
	
	angle += angle_step
	rotation.y += -angle_step
	rotation.z = -clamp(angle_dist, -PI / 4, PI / 4)
	
	translate(Vector3.FORWARD * SPEED * delta)
	
	if abs(angle_dist) < 0.2 and target and target.global_position.distance_to(global_position) < 100.0:
		weapon.shot()

func _physics_process(_delta: float) -> void:
	var result = CollisionManager.check_collision(self)
	
	if result:
		result.add_damage(COLLISION_DAMAGE)
		death()
