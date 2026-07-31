extends ScenarioBase
## Dig order: a peasant walks to a spot, carves the terrain, and hauls the
## dug material back to storage — the quarry/mine loop on real voxels.

func _init() -> void:
	scenario_name = &"quarry"

func setup() -> void:
	var world := WorldBuilder.new()
	add_child(world)
	world.build(12345)
	Sim.start_sim(12345)
	Events.reset()

	var mgr := UnitManager.new()
	add_child(mgr)
	mgr.setup(world.shard, world)

	var dig_pos := Vector3(70.5, 0, 70.5)
	var h0: int = world.shard.get_height(70, 70)
	var p := mgr.spawn_peasant(Vector3(64.5, world.shard.get_height(64, 64), 64.5), 0)
	await get_tree().physics_frame
	p.order_dig(dig_pos, &"dirt")
	assert_true(p.brain.order == &"dig", "dig order set")

	# Let it dig + deposit for a while.
	for i in 1200:
		await get_tree().physics_frame
	var dug_down: int = world.shard.get_height(70, 70)
	assert_true(dug_down < h0, "terrain carved lower (%d -> %d)" % [h0, dug_down])
	assert_true(Events.get_amount(&"player", &"dirt") > 0, "dirt credited to storage (got %d)" % Events.get_amount(&"player", &"dirt"))
	Sim.stop_sim()
	finish()
