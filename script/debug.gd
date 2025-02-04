extends Control

func _process(_delta: float) -> void:
	queue_redraw()

func _draw() -> void:
	for item in CollisionManager._pool:
		if item.is_free:
			continue
		
		var rect = item.node.get_collision_rect()
		draw_rect(rect, Color(200, 0, 0, 100))
