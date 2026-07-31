class_name WorldBuilder
extends Node3D
## Builds the visible world: generates a VoxelShard, meshes it per 32x32 chunk,
## and adds lighting. Owns the shard reference for later gameplay systems.

const CHUNKS_X: int = int(VoxelShard.SIZE_X / float(LayerMesher.CHUNK_SIZE))
const CHUNKS_Z: int = int(VoxelShard.SIZE_Z / float(LayerMesher.CHUNK_SIZE))

var shard: VoxelShard
var water: WaterSim
var _mesher := LayerMesher.new()
var _material: StandardMaterial3D
var _chunks_node: Node3D
var _chunks: Dictionary = {}   # "cx,cz" -> MeshInstance3D
var _water_node: Node3D
var _water_meshes: Dictionary = {}  # "cx,cz" -> MeshInstance3D (translucent overlay)

func build(new_seed: int) -> void:
	shard = VoxelShard.new()
	shard.generate(new_seed)
	water = WaterSim.new(shard)
	_mesh_all_chunks()
	_water_node = Node3D.new()
	_water_node.name = "Water"
	add_child(_water_node)
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
	if delta < 0:
		# Digging can leave overhangs unsupported — settle them.
		settle(x, z, 1)

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

## Collapse physics (Phase 6): after digging, unsupported voxels are detected.
## A block is supported if it sits on the column below reaching the ground, or
## horizontally adjacent to a supported block. We flood-fill support from the
## ground up per column neighborhood; anything floating collapses (removed).
## Returns number of blocks that collapsed.
func collapse_around(x: int, z: int, radius: int = 1) -> int:
	var collapsed: int = 0
	for dx in range(-radius, radius + 1):
		for dz in range(-radius, radius + 1):
			collapsed += _collapse_column(x + dx, z + dz)
	return collapsed

func _collapse_column(x: int, z: int) -> int:
	if x < 0 or x >= VoxelShard.SIZE_X or z < 0 or z >= VoxelShard.SIZE_Z:
		return 0
	# Scan for floating runs: a solid block with air directly beneath it and no
	# solid lateral neighbor at its level. Drop the run down by one if there's
	# a gap; repeat handled by caller loops. Simple gravity settle.
	var fell: int = 0
	var h: int = shard.get_height(x, z)
	for y in range(1, h):
		var m: int = shard.get_material(x, y, z)
		if m != 0 and shard.get_material(x, y - 1, z) == 0:
			# Floating block at y: check lateral support at this level.
			if _has_lateral_support(x, y, z):
				continue
			# Drop it one step into the gap below.
			shard.set_material(x, y, z, 0)
			shard.set_material(x, y - 1, z, m)
			fell += 1
	if fell > 0:
		_remesh_around(x, z)
	return fell

func _has_lateral_support(x: int, y: int, z: int) -> bool:
	# Supported if any horizontal neighbor at the same level is solid AND that
	# neighbor is itself grounded (block below it solid).
	for d in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
		var nx: int = x + d.x
		var nz: int = z + d.y
		if shard.get_material(nx, y, nz) != 0 and shard.get_material(nx, y - 1, nz) != 0:
			return true
	return false

## Settle a region repeatedly until nothing else falls (multi-block overhangs
## take a few passes). Returns total blocks moved.
func settle(x: int, z: int, radius: int = 1, max_passes: int = 8) -> int:
	var total: int = 0
	for _i in max_passes:
		var n: int = collapse_around(x, z, radius)
		total += n
		if n == 0:
			break
	return total

## Render the current water overlay as translucent surface quads. Rebuilt on
## demand after water sim steps (cheap at this scale; region-sleep later).
func render_water() -> void:
	if _water_node == null or water == null:
		return
	for c in _water_node.get_children():
		c.queue_free()
	var mat := _water_material()
	var csize: int = LayerMesher.CHUNK_SIZE
	for cx in CHUNKS_X:
		for cz in CHUNKS_Z:
			var st := SurfaceTool.new()
			st.begin(Mesh.PRIMITIVE_TRIANGLES)
			var any: bool = false
			for lx in csize:
				for lz in csize:
					var x: int = cx * csize + lx
					var z: int = cz * csize + lz
					var lvl: int = water.level(x, z)
					if lvl <= 0:
						continue
					any = true
					var h: float = float(shard.get_height(x, z)) + 0.4 + float(lvl) * 0.06
					_add_water_quad(st, x, z, h, lvl)
			if any:
				st.generate_normals()
				var mi := MeshInstance3D.new()
				mi.mesh = st.commit()
				mi.material_override = mat
				_water_node.add_child(mi)

func _add_water_quad(st: SurfaceTool, x: int, z: int, y: float, lvl: int) -> void:
	var a: float = clampf(0.3 + float(lvl) * 0.06, 0.3, 0.75)
	var col := Color(0.25, 0.5, 0.85, a)
	st.set_color(col)
	st.set_normal(Vector3.UP)
	var x0: float = x + 0.05
	var x1: float = x + 0.95
	var z0: float = z + 0.05
	var z1: float = z + 0.95
	st.add_vertex(Vector3(x0, y, z0))
	st.add_vertex(Vector3(x1, y, z0))
	st.add_vertex(Vector3(x1, y, z1))
	st.add_vertex(Vector3(x0, y, z0))
	st.add_vertex(Vector3(x1, y, z1))
	st.add_vertex(Vector3(x0, y, z1))

func _water_material() -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.vertex_color_use_as_albedo = true
	m.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	m.roughness = 0.2
	m.metallic = 0.1
	return m

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
