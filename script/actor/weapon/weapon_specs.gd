class_name WeaponSpecs
extends Node

@export var UPGRADE_INDEX: int
@export var MUZZLES: Array[NodePath]
@export var DEVIATIONS: Array[float] = [0.0]

var _weapon: WeaponBase
var _muzzles: Array[Node3D]
var _flashes: Array[Node3D]

func get_weapon() -> WeaponBase:
	return get_parent() as WeaponBase

func shot():
	for flash in _flashes:
		flash.show()

	for i in len(_muzzles):
		var muzzle = _muzzles[i]
		var deviation = deg_to_rad(DEVIATIONS[i] if i < len(DEVIATIONS) else DEVIATIONS.back())
		_weapon.create_projectile(
			get_weapon().get_parent(), \
			muzzle.global_position, \
			muzzle.global_rotation - Vector3(0.0, deviation, 0.0))

func reset():
	for flash in _flashes:
		flash.hide()

func _ready() -> void:
	_weapon = get_parent() as WeaponBase
	
	for muzzle_path in MUZZLES:
		if muzzle_path:
			var muzzle_node = get_node_or_null(muzzle_path)
		
			if muzzle_node:
				_muzzles.append(muzzle_node)
			
			if muzzle_node.has_meta("Flash"):
				muzzle_node.hide()
				_flashes.append(muzzle_node)
