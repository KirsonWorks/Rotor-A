class_name LevelBase
extends Node3D

enum LevelState {NONE, SCROLL, FREEZE}

@export var FINISH_POINT: Vector3
@export var AUTOCLEAN_NODES: Array[Node3D]

var _player: Player
var _camera_velocity: Vector3
var _state: LevelState = LevelState.NONE

func set_player(player: Player) -> void:
	_player = player
	get_tree().call_group("enemy", "set_target", player)
	
func _ready() -> void:
	_state = LevelState.SCROLL
	
func _process(_delta: float) -> void:
	for node in AUTOCLEAN_NODES:
		_clear_unused_nodes(node)
		
	var enemy_count = get_tree().get_node_count_in_group("enemy")
	
	match _state:
		LevelState.SCROLL:
			if enemy_count > 0 and \
				_player.global_position.distance_to(FINISH_POINT) <= 200:
					_camera_velocity = Global.camera_velocity
					Global.camera_velocity = Vector3.ZERO
					_state = LevelState.FREEZE
		
		LevelState.FREEZE:
			if enemy_count == 0:
				Global.camera_velocity = _camera_velocity
				_state = LevelState.SCROLL
	
func _clear_unused_nodes(parent_node: Node, peek_amount: int = 10):
	var count = parent_node.get_child_count()
	
	if count == 0:
		return
	
	for i in peek_amount:
		var index = randi_range(0, count - 1)
		var node = parent_node.get_child(index) as Node3D 

		if Global.camera.is_position_behind(node.global_position):
			node.queue_free()
