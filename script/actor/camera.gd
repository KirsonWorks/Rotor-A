extends Camera3D

@export var MOTION_SPEED: float = 3.0
@export var BOUND_X: float = 50.0
@export_node_path("Node3D") var TARGET_PATH
@onready var target: Node3D = get_node_or_null(TARGET_PATH) if TARGET_PATH else null

func _process(delta: float) -> void:
	var parent = get_parent() as Node3D
	parent.position += Global.camera_velocity * delta
	
	if target:
		position.x = lerp(position.x, target.position.x, delta * MOTION_SPEED)

	position.x = clamp(position.x, -BOUND_X, BOUND_X)
