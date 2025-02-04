extends Node3D

@export var AXIS: Vector3 = Vector3.UP
@export var SPEED: float = TAU

func _process(delta: float) -> void:
	if not is_zero_approx(SPEED):
		rotate(AXIS, -SPEED * delta)
