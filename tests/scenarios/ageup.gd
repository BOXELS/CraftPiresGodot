extends ScenarioBase
## Age advancement: gated by resources AND a completed building; advancing bumps
## the age and (via techs) peasant stages.

func _init() -> void:
	scenario_name = &"ageup"

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
	assert_true(p.stage == PeasantStage.Stage.PRIMITIVE, "peasant starts primitive")

	var age_mgr := AgeManager.new(&"player")
	assert_true(age_mgr.age == TechTree.Age.PRIMITIVE, "starts in age 1")

	# Give resources but no barracks -> cannot advance.
	Events.add_resource(&"player", &"food", 500)
	Events.add_resource(&"player", &"stone", 300)
	assert_true(not age_mgr.can_advance_age(), "age advance needs barracks building")

	age_mgr.record_building(&"barracks")
	assert_true(age_mgr.can_advance_age(), "can advance once barracks built + stocked")
	assert_true(age_mgr.advance_age(mgr), "advanced to age 2")
	assert_true(age_mgr.age == TechTree.Age.METAL, "now in metal age")

	# Now wheel (age-2 tech) is researchable and bumps peasant stage.
	Events.add_resource(&"player", &"wood", 600)
	Events.add_resource(&"player", &"iron", 100)
	assert_true(age_mgr.can_research(&"wheel"), "wheel researchable in age 2")
	assert_true(age_mgr.research(&"wheel", mgr), "wheel researched")
	assert_true(p.stage == PeasantStage.Stage.WHEEL, "peasant bumped to wheel stage")
	assert_true(p.carry_capacity() == 50, "wheel carry capacity 50")
	finish()
