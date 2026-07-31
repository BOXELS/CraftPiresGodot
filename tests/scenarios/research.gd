extends ScenarioBase
## Tech research: spend resources through Events, unlock content, bump peasant
## stage for stage-granting techs, gated by age and affordability.

func _init() -> void:
	scenario_name = &"research"

func setup() -> void:
	Events.reset()
	var world := WorldBuilder.new()
	add_child(world)
	world.build(1)
	var mgr := UnitManager.new()
	add_child(mgr)
	mgr.setup(world.shard, world)
	var p := mgr.spawn_peasant(Vector3(10, 0, 10), 0)
	await get_tree().physics_frame

	var age_mgr := AgeManager.new(&"player")
	# Cannot afford masonry at start.
	assert_true(not age_mgr.can_research(&"masonry"), "masonry gated by resources")

	Events.add_resource(&"player", &"stone", 500)
	Events.add_resource(&"player", &"clay", 200)
	assert_true(age_mgr.can_research(&"masonry"), "masonry researchable when stocked")
	assert_true(age_mgr.research(&"masonry", mgr), "masonry researched")
	assert_true(age_mgr.is_unlocked(&"stone_wall"), "stone_wall unlocked by masonry")
	assert_true(age_mgr.researched.has(&"masonry"), "masonry recorded")
	# Resources spent.
	assert_true(Events.get_amount(&"player", &"stone") == 0, "masonry cost spent")

	# Cannot re-research.
	assert_true(not age_mgr.research(&"masonry", mgr), "cannot research twice")

	# Wheel (Age 2) not researchable while still Age 1.
	Events.add_resource(&"player", &"wood", 600)
	Events.add_resource(&"player", &"iron", 100)
	assert_true(not age_mgr.can_research(&"wheel"), "age-2 tech gated while age 1")
	finish()
