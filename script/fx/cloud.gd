extends CanvasLayer

func _process(_delta: float) -> void:
	if not Global.camera:
		return
	
	var shader = $Texture.material as ShaderMaterial
	var uv_offset = Vector2(Global.camera.position.x * 0.01, \
		Global.camera.global_position.z * 0.01)
	shader.set_shader_parameter("offset", uv_offset)
