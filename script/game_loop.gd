class_name GameLoop
extends SceneTree

const FADE_COLOR_IN: Color = Color.BLACK
const FADE_COLOR_OUT: Color = Color(FADE_COLOR_IN, 0.0)

var was_paused: bool = false
var screen_rect: ColorRect

func _initialize() -> void:
	root.process_mode = Node.PROCESS_MODE_ALWAYS
	
	var canvas_layer = CanvasLayer.new()
	screen_rect = ColorRect.new()
	
	root.add_child(canvas_layer)
	canvas_layer.layer = 100
	canvas_layer.process_mode = Node.PROCESS_MODE_ALWAYS
	screen_rect.color = Color(0.0, 0.0, 0.0, 0.0)
	canvas_layer.add_child(screen_rect)
	screen_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	screen_rect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

func _notification(what: int) -> void:
	match what:
		NOTIFICATION_APPLICATION_FOCUS_OUT:
			was_paused = paused
			paused = true
		
		NOTIFICATION_APPLICATION_FOCUS_IN:
			if not was_paused:
				paused = false

func change_scene(scene) -> void:
	await fade_in().finished
	
	if scene is String:
		change_scene_to_file(scene)
	elif scene is PackedScene:
		change_scene_to_packed(scene)
	else:
		printerr("'scene' must have string or PackedScene type")
	
	await fade_out().finished
	
func fade_in() -> Tweener:
	var fade_in = create_tween() \
		.tween_property(screen_rect, "color", FADE_COLOR_IN, 1.0) \
		.from(FADE_COLOR_OUT)

	return fade_in
	
func fade_out() -> Tweener:
	var fade_out = create_tween() \
		.tween_property(screen_rect, "color", FADE_COLOR_OUT, 1.0) \
		.from(FADE_COLOR_IN)
		
	return fade_out
