extends Node

const LIGHTFX_SCENE = preload("res://scene/fx/lightfx.tscn")
const LIGHTFX_POOL_SIZE = 20

@onready var camera: Camera3D = null

var camera_velocity: Vector3 = Vector3(0, 0, -20.0)
var projectiles_node: Node3D
var fx_node: Node3D
var lightfx_pool: Array

func setup() -> void:
	camera = get_viewport().get_camera_3d()
	
	if not projectiles_node:
		projectiles_node = _add_node3d("Projectiles")
	
	if not fx_node:
		fx_node = _add_node3d("Fx")
	
	lightfx_pool.clear()
	for i in range(LIGHTFX_POOL_SIZE):
		var item = LIGHTFX_SCENE.instantiate()
		lightfx_pool.push_back(item)
		fx_node.add_child(item)

func create_explosion(position: Vector3) -> void:
	_create_lightfx(position, "explosion")

func create_hitflare(position: Vector3) -> void:
	_create_lightfx(position, "hitflare")

func _create_lightfx(position: Vector3, animation_name: StringName) -> void:
	var node: Node3D = null
	var animation: AnimationPlayer = null
	
	for item in lightfx_pool:
		animation = item.get_node("Anim") as AnimationPlayer
		
		if not animation.is_playing():
			node = item
			break
	
	if node:
		node.global_position = position
		animation.play("RESET")
		animation.queue(animation_name)
	
func _add_node3d(node_name: StringName) -> Node3D:
	var node = Node3D.new()
	node.name = node_name
	get_tree().current_scene.add_child(node)
	return node

func _ready() -> void:
	randomize()
