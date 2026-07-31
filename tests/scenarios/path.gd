extends ScenarioBase
## Phase 1 smoke test: shard generation + camera rig + mesher sanity.

func _init() -> void:
	scenario_name = &"path"

func _ready() -> void:
	super()
	var shard := VoxelShard.new()
	shard.generate(12345)
	assert_true(shard.get_height(10, 10) > 0, "shard generated nonzero heights")
	assert_true(shard.surface_material(10, 10) != 0, "surface material present")

	# Same seed regenerates identically.
	var shard2 := VoxelShard.new()
	shard2.generate(12345)
	assert_true(shard.get_height(50, 50) == shard2.get_height(50, 50), "seeded generation deterministic")

	# Digging the top voxel lowers the height.
	var x: int = 30
	var z: int = 30
	var before: int = shard.get_height(x, z)
	shard.set_material(x, before - 1, z, 0)
	assert_true(shard.get_height(x, z) == before - 1, "digging updates heightmap")

	# Mesher produces geometry for a chunk.
	var mesher := LayerMesher.new()
	var mesh := mesher.build_chunk_mesh(shard, 0, 0)
	assert_true(mesh != null, "chunk mesh built")
	assert_true(mesh.get_surface_count() > 0, "chunk mesh has a surface")

	# Camera rig constructs with a camera child.
	var rig := CameraRig.new()
	add_child(rig)
	assert_true(rig.get_node_or_null("Camera3D") != null, "camera rig has Camera3D")

	finish()
