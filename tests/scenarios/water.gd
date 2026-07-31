extends ScenarioBase
## Water: poured on a slope, it flows downhill deterministically; flat ground
## equalizes; draining removes it.

func _init() -> void:
	scenario_name = &"water"

func setup() -> void:
	var world := WorldBuilder.new()
	add_child(world)
	world.build(12345)
	await get_tree().physics_frame
	var water := WaterSim.new(world.shard)

	# Find a downhill pair: a higher column next to a lower one.
	var hx: int = -1
	var hz: int = -1
	var lx: int = -1
	var lz: int = -1
	for x in range(20, 108):
		for z in range(20, 108):
			var h0: int = world.shard.get_height(x, z)
			var h1: int = world.shard.get_height(x + 1, z)
			if h0 - h1 >= 2:
				hx = x; hz = z; lx = x + 1; lz = z
				break
		if hx >= 0:
			break
	assert_true(hx >= 0, "found a downhill slope for water test")
	print("[water] high (%d,%d) h=%d -> low (%d,%d) h=%d" % [hx, hz, world.shard.get_height(hx, hz), lx, lz, world.shard.get_height(lx, lz)])

	# Pour water on the high cell; step; it should flow to a lower neighbor.
	water.set_water(hx, hz, 4)
	assert_true(water.level(hx, hz) == 4, "water poured on high cell")
	var moved: int = water.step(0, 0, VoxelShard.SIZE_X, VoxelShard.SIZE_Z)
	assert_true(moved > 0, "water moved this step")
	assert_true(water.level(hx, hz) < 4, "high cell lost water to flow")
	# Some lower neighbor gained the water.
	var gained: bool = false
	for d in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
		if water.level(hx + d.x, hz + d.y) > 0:
			gained = true
	assert_true(gained, "water flowed to a lower neighbor")

	# Drain removes water.
	var before_drain: int = 0
	var dx0: int = -1
	var dz0: int = -1
	for d in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
		if water.level(hx + d.x, hz + d.y) > 0:
			dx0 = hx + d.x; dz0 = hz + d.y; before_drain = water.level(dx0, dz0)
	var took: int = water.drain(dx0, dz0, 99)
	assert_true(took == before_drain and took > 0, "drain removed water (took %d)" % took)
	finish()
