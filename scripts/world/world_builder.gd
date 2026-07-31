class_name WorldBuilder
extends Node3D
## Builds the visible world: generates a VoxelShard, meshes it per 32x32 chunk,
## and adds lighting. Owns the shard reference for later gameplay systems.

const CHUNKS_X: int = int(VoxelShard.SIZE_X / float(LayerMesher.CHUNK_SIZE))
const CHUNKS_Z: int = int(VoxelShard.SIZE_Z / float(LayerMesher.CHUNK_SIZE))

var shard: VoxelShard
var _mesher := LayerMesher.new()
var _material: StandardMaterial3D
var _chunks_node: Node3D
var _chunks: Dictionary = {}   # "cx,cz" -> MeshInstance3D

func build(new_seed: int) -> void:
	shard = VoxelShard.new()
	shard.generate(new_seed)
	_mesh_all_chunks()
	_add_lighting()

func _mesh_all_chunks() -> void:
	_material = LayerMesher.make_material()
	_chunks_node = Node3D.new()
	_chunks_node.name = "Chunks"
	add_child(_chunks_node)
	for cx in CHUNKS_X:
		for cz in CHUNKS_Z:
			var mi := _make_chunk(cx, cz)
			_chunks_node.add_child(mi)
			_chunks[_key(cx, cz)] = mi

func _key(cx: int, cz: int) -> String:
	return "%d,%d" % [cx, cz]

func _make_chunk(cx: int, cz: int) -> MeshInstance3D:
	var mesh := _mesher.build_chunk_mesh(shard, cx, cz)
	var mi := MeshInstance3D.new()
	mi.name = "chunk_%d_%d" % [cx, cz]
	mi.mesh = mesh
	mi.material_override = _material
	# Static collision so terrain raycasting (click-to-move / beam) works.
	var body := StaticBody3D.new()
	var col := CollisionShape3D.new()
	col.shape = mesh.create_trimesh_shape()
	body.add_child(col)
	mi.add_child(body)
	return mi

## Edit a single voxel column-top. delta < 0 digs (removes `amount` blocks),
## delta > 0 raises with `material`. Re-meshes affected chunks live.
func edit_voxel(x: int, z: int, delta: int, material: int = 3) -> void:
	if x < 0 or x >= VoxelShard.SIZE_X or z < 0 or z >= VoxelShard.SIZE_Z:
		return
	var h: int = shard.get_height(x, z)
	if delta < 0:
		# Dig: remove the top -delta blocks.
		for i in range(h - 1, maxi(h + delta - 1, -1), -1):
			shard.set_material(x, i, z, 0)
	elif delta > 0:
		for i in range(h, mini(h + delta, VoxelShard.MAX_Y)):
			shard.set_material(x, i, z, material)
	_remesh_around(x, z)

func dig(x: int, z: int, amount: int = 1) -> void:
	edit_voxel(x, z, -amount)

func raise(x: int, z: int, amount: int = 1, material: int = 2) -> void:
	edit_voxel(x, z, amount, material)

func _remesh_around(x: int, z: int) -> void:
	# Rebuild the chunk containing (x,z) plus any neighbor chunk the edit
	# touches on a border (faces at the seam are shared).
	var csize: int = LayerMesher.CHUNK_SIZE
	var cx: int = int(x / float(csize))
	var cz: int = int(z / float(csize))
	var to_rebuild: Dictionary = {_key(cx, cz): true}
	if x % csize == 0 and cx > 0:
		to_rebuild[_key(cx - 1, cz)] = true
	if x % csize == csize - 1 and cx < CHUNKS_X - 1:
		to_rebuild[_key(cx + 1, cz)] = true
	if z % csize == 0 and cz > 0:
		to_rebuild[_key(cx, cz - 1)] = true
	if z % csize == csize - 1 and cz < CHUNKS_Z - 1:
		to_rebuild[_key(cx, cz + 1)] = true
	for k in to_rebuild:
		var parts: PackedStringArray = k.split(",")
		_rebuild_chunk(int(parts[0]), int(parts[1]))

func _rebuild_chunk(cx: int, cz: int) -> void:
	var k := _key(cx, cz)
	if not _chunks.has(k):
		return
	var old: MeshInstance3D = _chunks[k]
	var idx: int = old.get_index()
	old.queue_free()
	var mi := _make_chunk(cx, cz)
	_chunks_node.add_child(mi)
	_chunks_node.move_child(mi, idx)
	_chunks[k] = mi

func _add_lighting() -> void:
	var sun := DirectionalLight3D.new()
	sun.name = "Sun"
	sun.rotation_degrees = Vector3(-50.0, -30.0, 0.0)
	sun.shadow_enabled = true
	sun.light_energy = 1.1
	add_child(sun)

	var env := WorldEnvironment.new()
	var e := Environment.new()
	e.background_mode = Environment.BG_SKY
	e.sky = Sky.new()
	var sky_mat := ProceduralSkyMaterial.new()
	sky_mat.sky_top_color = Color(0.45, 0.65, 0.9)
	sky_mat.sky_horizon_color = Color(0.75, 0.85, 0.95)
	e.sky.sky_material = sky_mat
	e.ambient_light_source = Environment.AMBIENT_SOURCE_SKY
	e.ambient_light_energy = 0.6
	env.environment = e
	add_child(env)
