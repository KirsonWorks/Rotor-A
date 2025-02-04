extends BoxContainer

@export var ICON_TEXTURE: Texture2D

func inc() -> void:
	var icon = TextureRect.new()
	icon.texture = ICON_TEXTURE
	icon.expand_mode = TextureRect.EXPAND_FIT_WIDTH
	add_child(icon)

func dec() -> void:
	var count = get_child_count()
	
	if count == 0:
		return
	
	var last = get_child(count - 1)
	remove_child(last)
	
func add_range(count: int) -> void:
	if count <= 0:
		return
	
	for i in range(count):
		inc()
		
func clear() -> void:
	while get_child_count() > 0:
		dec()
