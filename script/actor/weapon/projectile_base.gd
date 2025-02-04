class_name ProjectileBase
extends Actor

@export var IS_RAY: bool = false
@export var INITIAL_SPEED: float = 150.0
@export var ACCELERATION: float = 250.0
@export_range(1.0, 1000.0) var DAMAGE: float = 25.0
@export_range(0.0, 100.0, 0.1) var DAMAGE_SCALE: float = 1.0
@export_range(0.1, 10.0, 0.1) var LIFE_TIME_LIMIT: float = 1.5
@onready var speed: float = INITIAL_SPEED

var _life_time = 0.0

func _process(delta: float) -> void:
	_life_time += delta
	
	if not IS_RAY:
		speed += ACCELERATION * delta
		translate(Vector3.FORWARD * speed * delta)
	
	if _life_time >= LIFE_TIME_LIMIT:
		queue_free()

func _physics_process(delta: float) -> void:
	var result = CollisionManager.check_collision(self)
	
	if not result:
		return

	var damage_delta = delta if IS_RAY else 1.0
	result.add_damage(DAMAGE * DAMAGE_SCALE * damage_delta)

	if not IS_RAY:
		Global.create_hitflare(global_position)
		queue_free()
