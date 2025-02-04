extends Node3D

@export var LEVELS: Array[PackedScene] = []
@export var CURRENT_LEVEL_INDEX: int = 0

enum GameState {NONE, RUN, COMPLETED}

var _level_node: Node
var _lifes: int = 3
var _initial_lifes: int
var _initial_position: Vector3
var _initial_weapon_spec_index: int = 0
var _state: GameState = GameState.NONE

func _start_level() -> void:
	_initial_lifes = _lifes
	_initial_weapon_spec_index = %Player.primary_weapon_specs_index
	_restart_level()

func _restart_level() -> void:
	_lifes = _initial_lifes
	
	if _level_node:
		remove_child(_level_node)
	
	_level_node = self.LEVELS[CURRENT_LEVEL_INDEX].instantiate() as LevelBase
	add_child(_level_node)
	_level_node.set_player(%Player)
	
	%LifeRepeater.clear()
	%LifeRepeater.add_range(_lifes)
	$PlayerHolder.global_position = _initial_position
	%Player.primary_weapon_specs_index = _initial_weapon_spec_index
	%Player.respawn()
	
	_state = GameState.RUN

func _set_pause(value: bool) -> bool:
	get_tree().paused = value
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE if value else Input.MOUSE_MODE_CAPTURED
	return value

func _input(event: InputEvent) -> void:
	if event.is_action_released("ui_cancel"):
		%PauseDialog.visible = _set_pause(true)

func _ready() -> void:
	Global.setup()
	_initial_position = $PlayerHolder.global_position
	_start_level()
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _process(_delta: float) -> void:
	if _state == GameState.RUN and \
		$PlayerHolder.global_position.z < _level_node.FINISH_POINT.z:
			%LevelCompleteDialog.visible = _set_pause(true)
			_state = GameState.COMPLETED

	var obj_count = Performance.get_monitor(Performance.OBJECT_NODE_COUNT)
	var obj_render_count = Performance.get_monitor(Performance.RENDER_TOTAL_OBJECTS_IN_FRAME)
	$HUD/Debug/ObjectCount.text = "%d/%d" % [obj_count, obj_render_count]

func _on_player_health_changed(value: float) -> void:
	%HealthBar.value = value
	%LabelHealth.text = "%d" % value

func _on_button_continue_pressed() -> void:
	%PauseDialog.visible = _set_pause(false)

func _on_button_exit_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene("res://scene/scene_menu.tscn")
	
func _on_player_died() -> void:
	_lifes -= 1
	%LifeRepeater.dec()
	
	if _lifes < 0:
		%GameoverDialog.visible = _set_pause(true)
		return
	
	await get_tree().create_timer(2.0).timeout
	%Player.respawn()

func _next_or_restart_level(next: bool) -> void:
	_set_pause(false)
	%PauseDialog.hide()
	%GameoverDialog.hide()
	%LevelCompleteDialog.hide()
	
	if not next:
		await get_tree().fade_in().finished
		_restart_level()
		await get_tree().fade_out().finished
		return

	if CURRENT_LEVEL_INDEX < len(LEVELS) - 1:
		CURRENT_LEVEL_INDEX += 1
		await get_tree().fade_in().finished
		_start_level()
		await get_tree().fade_out().finished
	else:
		_on_button_exit_pressed()
