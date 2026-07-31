class_name LayerMesher
extends RefCounted
## Meshes voxel surface data into chunk meshes with hidden-face culling and
## per-material vertex colors. Naive per-face generation first; greedy meshing
## comes later only if profiling demands it.

const CHUNK_SIZE: int = 32

const MATERIAL_COLORS: Dictionary = {
	1: Color(0.38, 0.62, 0.30),  # grass
	2: Color(0.45, 0.32, 0.20),  # dirt
	3: Color(0.52, 0.52, 0.55),  # stone
	4: Color(0.85, 0.78, 0.55),  # sand
	5: Color(0.90, 0.92, 0.95),  # snow
	6: Color(0.30, 0.45, 0.70),  # water (later)
}

# Faces: dir, 4 corners (CCW from outside)
const FACES: Array = [
	{"n": Vector3i(0, 1, 0),  "v": [Vector3i(0,1,0), Vector3i(1,1,0), Vector3i(1,1,1), Vector3i(0,1,1)]},  # top
	{"n": Vector3i(0, -1, 0), "v": [Vector3i(0,0,1), Vector3i(1,0,1), Vector3i(1,0,0), Vector3i(0,0,0)]},  # bottom
	{"n": Vector3i(1, 0, 0),  "v": [Vector3i(1,0,1), Vector3i(1,1,1), Vector3i(1,1,0), Vector3i(1,0,0)]},  # east
	{"n": Vector3i(-1, 0, 0), "v": [Vector3i(0,0,0), Vector3i(0,1,0), Vector3i(0,1,1), Vector3i(0,0,1)]},  # west
	{"n": Vector3i(0, 0, 1),  "v": [Vector3i(0,0,1), Vector3i(0,1,1), Vector3i(1,1,1), Vector3i(1,0,1)]},  # south
	{"n": Vector3i(0, 0, -1), "v": [Vector3i(1,0,0), Vector3i(1,1,0), Vector3i(0,1,0), Vector3i(0,0,0)]},  # north
]

## Build a mesh for one 32x32 chunk. cx/cz are chunk coordinates.
func build_chunk_mesh(shard: VoxelShard, cx: int, cz: int) -> ArrayMesh:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var base_x: int = cx * CHUNK_SIZE
	var base_z: int = cz * CHUNK_SIZE

	for lx in CHUNK_SIZE:
		for lz in CHUNK_SIZE:
			var x: int = base_x + lx
			var z: int = base_z + lz
			var h: int = shard.get_height(x, z)
			for y in h:
				var mat: int = shard.get_material(x, y, z)
				if mat == 0:
					continue
				for face in FACES:
					var n: Vector3i = face["n"]
					var nx: int = x + n.x
					var ny: int = y + n.y
					var nz: int = z + n.z
					if shard.get_material(nx, ny, nz) != 0:
						continue
					_add_face(st, Vector3(x, y, z), face, MATERIAL_COLORS.get(mat, Color.MAGENTA))

	st.generate_normals()
	return st.commit()

func _add_face(st: SurfaceTool, origin: Vector3, face: Dictionary, color: Color) -> void:
	var n: Vector3 = Vector3(face["n"])
	var corners: Array = face["v"]
	st.set_color(color)
	st.set_normal(n)
	# Two triangles: 0-1-2, 0-2-3
	var p: Array = []
	for c in corners:
		p.append(origin + Vector3(c))
	st.add_vertex(p[0])
	st.add_vertex(p[1])
	st.add_vertex(p[2])
	st.add_vertex(p[0])
	st.add_vertex(p[2])
	st.add_vertex(p[3])

## Vertex-colored material with simple lambert shading via vertex color * lighting.
static func make_material() -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.vertex_color_use_as_albedo = true
	m.roughness = 0.9
	m.metallic = 0.0
	return m
