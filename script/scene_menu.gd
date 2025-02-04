extends Node

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _on_button_start_pressed() -> void:
	get_tree().change_scene("res://scene/scene_game.tscn")

func _on_button_quit_pressed() -> void:
	get_tree().quit()

func _on_check_box_fullscreen_toggled(toggled_on: bool) -> void:
	var mode = DisplayServer.WINDOW_MODE_FULLSCREEN \
		if toggled_on else DisplayServer.WINDOW_MODE_WINDOWED
	
	DisplayServer.window_set_mode(mode)
