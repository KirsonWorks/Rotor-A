@tool
extends MeshInstance3D

@export_group("Height Map")
@export var DEBUG: bool:
	get:
		return DEBUG
	set(value):
		DEBUG = value
		_rebuild_mesh_if_editor_hint()

@export var SCALE: Vector3 = Vector3.ONE:
	get:
		return SCALE
	set(value):
		SCALE = value
		_rebuild_mesh_if_editor_hint()

@export var HEIGHTMAP: Texture2D:
	get:
		return HEIGHTMAP
	set(value):
		HEIGHTMAP = value
		_rebuild_mesh_if_editor_hint()

@export var GRADIENTMAP: GradientTexture1D:
	get:
		return GRADIENTMAP
	set(value):
		GRADIENTMAP = value
		_rebuild_mesh_if_editor_hint()

@export var UV_SCALE: float = 1.0:
	get:
		return UV_SCALE
	set(value):
		UV_SCALE = value
		_rebuild_mesh_if_editor_hint()

func _ready() -> void:
	_build_mesh_from_texture(HEIGHTMAP, GRADIENTMAP, SCALE, UV_SCALE)

func _rebuild_mesh_if_editor_hint():
	if Engine.is_editor_hint():
		_build_mesh_from_texture(HEIGHTMAP, GRADIENTMAP, SCALE, UV_SCALE)
		notify_property_list_changed()

func _build_mesh_from_texture(texture: Texture2D, gradientmap: GradientTexture1D, scale: Vector3, uv_scale: float) -> void:
	if not texture:
		mesh = null
		return

	var image = texture.get_image()
	
	if image == null:
		await texture.changed
		image = texture.get_image()
		
	if image.is_compressed():
		image.decompress()

	image.convert(Image.FORMAT_L8)
	
	var material = get_active_material(0)
	var gradientmap_image = gradientmap.get_image() if gradientmap else null
	mesh = _build_mesh(image.get_data(), gradientmap_image, image.get_width(), image.get_height(), scale, uv_scale)
	mesh.surface_set_material(0, material)

func _build_mesh(data: PackedByteArray, gradientmap: Image, \
		width: int, height: int, scale: Vector3, uv_scale) -> ArrayMesh:
	assert(data != null)
	assert(not data.is_empty())
	assert(width > 0)
	assert(height > 0)
	
	var verts = PackedVector3Array()
	verts.resize(width * height)
	
	var indicies = PackedInt32Array()

	var colors = PackedColorArray()
	colors.resize(verts.size())
	
	var normals = PackedVector3Array()
	normals.resize(verts.size())
	
	var tex_uv = PackedVector2Array()
	tex_uv.resize(verts.size())
	
	var uv_aspect = float(height) / float(width)
	var uv_shift = (Vector2(1.0, height / width) if uv_aspect > 1.0 else \
		Vector2(width / height, 1.0)) * uv_scale
	
	for y in height:
		var vz = -height / 2 + y
		for x in width:
			var i = y * width + x
			# calc vertex
			#var p = pow(float(-width / 2 + x) / (width / 2), 2.0) + 1
			var vx = -width / 2 + x #* p
			var vy = float(data[y * width + x]) / 255.0
			var vertex = Vector3(vx, vy, vz) * scale
			
			verts[i] = vertex
			
			# calc texture uv
			tex_uv[i] = Vector2((float(x) / width) * uv_shift.x, (float(y) / height) * uv_shift.y)
			
			if gradientmap:
				#calc vertex color
				var color_index = floor((vertex.y / scale.y) * (gradientmap.get_width() - 1))
				colors[i] = gradientmap.get_pixel(color_index, 0)
	
	# calc indicies
	for y in height - 1:
		for x in width - 1:
			var current = y * width + x
			var bottom = (y + 1) * width + x
			
			indicies.append(current)
			indicies.append(current + 1)
			indicies.append(bottom)
			
			# calc face normal
			var faceNormal = calc_face_normal( \
				verts[current], \
				verts[current + 1], \
				verts[bottom])
			
			normals[current] += faceNormal;
			normals[current + 1] += faceNormal;
			normals[bottom] += faceNormal;
			
			indicies.append(current + 1)
			indicies.append(bottom + 1)
			indicies.append(bottom)

			faceNormal = calc_face_normal( \
				verts[current + 1], \
				verts[bottom + 1], \
				verts[bottom])
			
			normals[current + 1] += faceNormal;
			normals[bottom + 1] += faceNormal;
			normals[bottom] += faceNormal;
	
	# calc vertex normals
	for i in normals.size():
		normals[i] = normals[i].normalized()
	
	var arrays = []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = verts
	arrays[Mesh.ARRAY_INDEX] = indicies
	arrays[Mesh.ARRAY_NORMAL] = normals
	arrays[Mesh.ARRAY_TEX_UV] = tex_uv
	
	if gradientmap:
		arrays[Mesh.ARRAY_COLOR] = colors
	
	var arrayMesh = ArrayMesh.new()
	arrayMesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	
	if DEBUG:
		arrayMesh.add_surface_from_arrays(Mesh.PRIMITIVE_LINES, \
			build_normal_lines_arrays(verts, normals))
	
	return arrayMesh

func build_normal_lines_arrays(vertsIn: PackedVector3Array, normalsIn: PackedVector3Array) -> Array:
	assert(vertsIn.size() == normalsIn.size())

	var arrays = []
	arrays .resize(Mesh.ARRAY_MAX)

	var vertCount = vertsIn.size()
	var verts = PackedVector3Array()
	verts.resize(vertCount * 2)
	
	var colors = PackedColorArray()
	colors.resize(vertCount * 2)

	var i = 0
	for v_index in vertsIn.size():
		verts[i] = vertsIn[v_index]
		verts[i + 1] = vertsIn[v_index] + normalsIn[v_index]
		colors[i] = Color.SKY_BLUE
		colors[i + 1] = Color.BLUE
		i += 2

	arrays[Mesh.ARRAY_VERTEX] = verts
	arrays[Mesh.ARRAY_COLOR] = colors
	
	return arrays
	
func calc_face_normal(v1: Vector3, v2: Vector3, v3: Vector3) -> Vector3 :
	var a = v1 - v2
	var b = v1 - v3
	return b.cross(a).normalized()
