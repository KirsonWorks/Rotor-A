class_name WeaponBase
extends Node

signal shooting()

@export var IS_PRIMARY: bool = true
@export_range(1, 2000) var RATE_OF_FIRE = 60
@export var PROJECTILE_SCENE: PackedScene
@export_flags_3d_physics var PROJECTILE_COLLISION_LAYER: int
@export_flags_3d_physics var PROJECTILE_COLLISION_MASK: int
@export_range(0.0, 100.0, 0.1) var PROJECTILE_DAMAGE_SCALE: float = 1.0
@onready var latency: float = 60.0 / max(1, RATE_OF_FIRE)
@onready var duration: float = min(0.05, latency)

enum State {NONE, IDLE, SHOT, SHOT_LATENCY}

var _time: float = 0.0
var _specs: WeaponSpecs
var _state: State = State.NONE

func _ready() -> void:
	if get_child_count() > 0:
		_specs = get_child(0)

	_change_state(State.IDLE)

func _process(delta: float) -> void:
	if _time > 0.0:
		_time -= delta
	else:
		match _state:
			State.SHOT:
				shooting.emit()
				_change_state(State.SHOT_LATENCY)
			
			State.SHOT_LATENCY:
				_change_state(State.IDLE)
 
func _change_state(new_state: State) -> void:
	if _state == new_state:
		return
	
	match new_state:
		State.SHOT:
			_specs.shot()
			_time = duration
		
		State.SHOT_LATENCY:
			_specs.reset()
			_time = latency

	_state = new_state

func shot() -> void:
	if _state == State.IDLE:
		_change_state(State.SHOT)

func use_specs(specs: WeaponSpecs) -> void:
	if specs.get_parent() != self:
		printerr("other weapon's specs")
	
	_specs = specs

func create_projectile(parent: Node, pos: Vector3, rot: Vector3):
	var projectile = PROJECTILE_SCENE.instantiate() as ProjectileBase
	projectile.COLLISION_LAYER = PROJECTILE_COLLISION_LAYER
	projectile.COLLISION_MASK = PROJECTILE_COLLISION_MASK
	projectile.DAMAGE_SCALE = PROJECTILE_DAMAGE_SCALE
	parent = parent if projectile.IS_RAY else Global.projectiles_node 
	parent.add_child(projectile)
	projectile.global_position = pos
	projectile.rotation = rot
