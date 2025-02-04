extends Node

const INITIAL_POOL_SIZE = 300

var _pool: Array[PoolItem]

func occupy(node: Actor) -> void:
	if _get_item(node):
		printerr("Node already exists")
		return

	_occupy_item(node)

func deoccupy(node: Actor) -> void:
	var item = _get_item(node)
	
	if item:
		item.node = null
		item.is_free = true
	else:
		printerr("Item not found")

func check_collision(node: Actor) -> Actor:
	if not node.can_collide():
		return null
	
	var items = _filter(node)
	
	if len(items) == 0:
		return null
	
	var r1 = node.get_collision_rect()
	
	for item in items:
		var r2 = item.node.get_collision_rect()
		
		if not r2.has_area():
			continue
		
		if r1.intersection(r2):
			return item.node

	return null

func _ready() -> void:
	for i in INITIAL_POOL_SIZE:
		_create_item()

func _get_item(node: Actor) -> PoolItem:
	for item in _pool:
		if item.node == node:
			return item
	
	return null

func _occupy_item(node: Actor) -> PoolItem:
	var result: PoolItem = null
	
	for item in _pool:
		if item.is_free:
			result = item
			break
	
	if not result:
		result = _create_item()
	
	result.node = node
	result.is_free = false
	return result
	
func _create_item() -> PoolItem:
	var item = PoolItem.new()
	item.is_free = true
	_pool.push_back(item)
	return item

func _filter(node: Actor) -> Array[PoolItem]:
	#_pool.filter(..) is slow
	var array: Array[PoolItem] = []
	
	for item in _pool:
		if not item.is_free and \
			item.node != node and \
			item.node.can_collide() and \
			(item.node.COLLISION_LAYER & node.COLLISION_MASK) > 0:
			array.push_back(item)
	
	return array

class PoolItem:
	var node: Actor
	var is_free: bool
