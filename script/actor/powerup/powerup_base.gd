class_name PowerupBase
extends Actor

func collect(_player: Player) -> void:
	pass

func _process(delta: float) -> void:
	rotate_y(PI * delta)

func _physics_process(_delta: float) -> void:
	var result = CollisionManager.check_collision(self)
	
	if result and result is Player:
		collect(result as Player)
		queue_free()
