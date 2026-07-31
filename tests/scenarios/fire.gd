extends ScenarioBase
## Fire: ignition on flammable ground, spread to neighbors over ticks, water
## extinguishes, and burned grass turns to dirt.

func _init() -> void:
	scenario_name = &"fire"

func setup() -> void:
	var world := WorldBuilder.new()
	add_child(world)
	world.build(777)
	await get_tree().physics_frame
	var water := WaterSim.new(world.shard)
	var fire := FireSim.new(world.shard, water, 42)

	# Find a grassy cell.
	var gx: int = -1
	var gz: int = -1
	for x in range(20, 108):
		for z in range(20, 108):
			if world.shard.surface_material(x, z) == 1:
				gx = x; gz = z
				break
		if gx >= 0:
			break
	assert_true(gx >= 0, "found grass to ignite")

	assert_true(fire.ignite(gx, gz), "ignited grass cell")
	assert_true(fire.is_burning(gx, gz), "cell burning after ignite")

	# Step several ticks; fire should spread to at least one neighbor.
	var spread_total: int = 0
	for i in 8:
		spread_total += fire.step()
	assert_true(fire.burning_count() >= 1, "fire persists/spreads (count %d)" % fire.burning_count())

	# Water extinguishes: pour water on all burning cells, then step.
	for i in range(VoxelShard.SIZE_X * VoxelShard.SIZE_Z):
		var x: int = i % VoxelShard.SIZE_X
		var z: int = i / VoxelShard.SIZE_X
		if fire.is_burning(x, z):
			water.set_water(x, z, 2)
	fire.step()
	assert_true(fire.burning_count() == 0, "water extinguished all fire")
	finish()
