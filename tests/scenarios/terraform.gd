extends ScenarioBase
## Terrain editing: digging lowers a column, raising lifts it, and the world
## re-meshes so the change is visible (surface material / height update).

func _init() -> void:
	scenario_name = &"terraform"

func setup() -> void:
	var world := WorldBuilder.new()
	add_child(world)
	world.build(12345)
	await get_tree().physics_frame

	var x: int = 64
	var z: int = 64
	var h0: int = world.shard.get_height(x, z)
	assert_true(h0 > 4, "column starts with diggable height")

	# Dig 3 blocks down.
	world.dig(x, z, 3)
	assert_true(world.shard.get_height(x, z) == h0 - 3, "dig lowers height by 3 (got %d)" % world.shard.get_height(x, z))
	var top_after_dig: int = world.shard.surface_material(x, z)
	assert_true(top_after_dig != 0, "dug column still has a surface block")

	# Raise 2 back with dirt (material 2).
	world.raise(x, z, 2, 2)
	assert_true(world.shard.get_height(x, z) == h0 - 1, "raise restores 2 blocks")
	assert_true(world.shard.surface_material(x, z) == 2, "raised top is dirt")

	# Cross a chunk border edit re-meshes both sides without error.
	world.dig(31, 64, 1)   # border between chunk 0 and 1 in x
	world.dig(32, 64, 1)
	finish()
