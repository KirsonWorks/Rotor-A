class_name Actor
extends Node3D

signal health_changed(value: float)

@export_range(0.0, 100.0) var HEALTH: float = 100.0:
	get: return HEALTH
	set(value):
		value = clamp(value, 0.0, 100.0)
		if not is_equal_approx(value, HEALTH):
			HEALTH = value
			health_changed.emit(value)

@export_range(0.1, 100.0, 0.1) var ARMOR: float = 1.0
@export var COLLISION_RECT_DECREASE: float = 0.2
@export_flags_3d_physics var COLLISION_LAYER: int
@export_flags_3d_physics var COLLISION_MASK: int
@export_node_path("VisualInstance3D") var COLLISION_MESH_PATH: NodePath

@onready var collision_mesh: VisualInstance3D = get_node_or_null(COLLISION_MESH_PATH) \
	if COLLISION_MESH_PATH else null

var _cached_collision_rect: Rect2

func add_health(value: float) -> void:
	HEALTH += value

func add_damage(damage: float) -> void:
	damage = damage / ARMOR

	if damage <= 0.0:
		return
	
	add_health(-damage)

func get_collision_rect() -> Rect2:
	if _cached_collision_rect.has_area():
		return _cached_collision_rect
	
	if not can_collide():
		return Rect2()

	var aabb = collision_mesh.get_aabb()
	var verts = PackedVector2Array()
	verts.resize(8)
	
	for i in range(8):
		var local_pos = aabb.position + aabb.size * Vector3(i / 4, (i % 4) / 2, i % 2)
		var global_pos = collision_mesh.to_global(local_pos)
		verts[i] = Global.camera.unproject_position(global_pos)

	var rect = Rect2(verts[0], Vector2.ZERO)
	
	for i in range(1, 8):
		rect = rect.expand(verts[i])
	
	var hv = rect.size * COLLISION_RECT_DECREASE
	_cached_collision_rect = rect.grow(-max(hv.x, hv.y))
	
	return _cached_collision_rect

func can_collide() -> bool:
	return collision_mesh and \
		is_visible_in_tree() and \
		Global.camera.is_position_in_frustum(global_position)

func _notification(what: int) -> void:
	if what == NOTIFICATION_PHYSICS_PROCESS:
		_cached_collision_rect = Rect2()

# don't remove
func _physics_process(_delta: float) -> void:
	pass

func _enter_tree() -> void:
	CollisionManager.occupy(self)

func _exit_tree() -> void:
	CollisionManager.deoccupy(self)
