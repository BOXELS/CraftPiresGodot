extends ScenarioBase
## Construction: a house site is placed, a peasant hauls materials from storage
## and builds it through all phases to completion.

func _init() -> void:
	scenario_name = &"build"

func setup() -> void:
	var world := WorldBuilder.new()
	add_child(world)
	world.build(12345)
	Sim.start_sim(12345)
	Events.reset()

	# Stock the depot with enough wood+stone for a house.
	var depot := StorageDepot.new(&"player")
	Events.add_resource(&"player", &"wood", 100)
	Events.add_resource(&"player", &"stone", 100)

	var buildings := BuildingsManager.new()
	add_child(buildings)
	buildings.setup(world.shard)
	var tile := Vector3i(60, 0, 60)
	var site := buildings.place(&"house", tile, &"player")
	assert_true(site != null, "house site placed")
	assert_true(site.needed_material() == &"wood", "site needs wood first")

	# Peasant hauls and builds.
	var mgr := UnitManager.new()
	add_child(mgr)
	mgr.setup(world.shard)
	var p := mgr.spawn_peasant(Vector3(56.5, world.shard.get_height(56, 56), 56.5), 0)
	await get_tree().physics_frame
	p.order_haul(site, depot)
	assert_true(p.brain.order == &"haul", "haul order set")

	# Run until the building completes (haul + build), with a frame budget.
	var done_flag: Array = [false]
	site.completed.connect(func(_k: StringName) -> void: done_flag[0] = true)
	for i in 3000:
		await get_tree().physics_frame
		if done_flag[0]:
			break
	assert_true(done_flag[0], "house reached completion")
	assert_true(site.phase == ConstructionSite.Phase.DONE, "site phase DONE")
	assert_true(buildings.completed.has(&"house"), "manager recorded completed house")
	Sim.stop_sim()
	finish()
