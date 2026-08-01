extends ScenarioBase
## AoE2 selection: single / toggle / double-click-same-type / box, and the
## context command routing (peasants gather a tree, dig bare ground, build).

func _init() -> void:
	scenario_name = &"selection"

func setup() -> void:
	var world := WorldBuilder.new()
	add_child(world)
	world.build(12345)
	await get_tree().physics_frame

	var units := UnitManager.new()
	add_child(units)
	units.setup(world.shard, world)
	var commander := Commander.new()
	add_child(commander)
	commander.setup(world.shard, 0)

	var camera := CameraRig.new()
	add_child(camera)
	await get_tree().physics_frame

	var sel := SelectionManager.new()
	add_child(sel)
	sel.setup(units, commander, camera)

	# Spawn a handful of peasants.
	for i in 4:
		units.spawn_peasant(Vector3(40.0 + float(i), 0, 40.0), 0)
	assert_true(sel.count() == 0, "nothing selected at start")

	# Single select.
	var p0: Peasant = units.peasants[0]
	sel.select_only(p0)
	assert_true(sel.count() == 1 and sel.is_selected(p0), "select_only selects one peasant")

	# Toggle adds / removes.
	var p1: Peasant = units.peasants[1]
	sel.toggle(p1)
	assert_true(sel.count() == 2, "shift-toggle adds a second peasant")
	sel.toggle(p1)
	assert_true(sel.count() == 1 and not sel.is_selected(p1), "shift-toggle removes it again")

	# Select-all-peasants equivalent.
	var all: Array = []
	for p in units.peasants:
		all.append(p)
	sel.set_selection(all)
	assert_true(sel.count() == 4, "set_selection selects all four")
	assert_true(sel.peasants().size() == 4, "peasants() filters the selection")

	# Commander in the pool + has_commander.
	sel.select_only(commander)
	assert_true(sel.has_commander(), "commander selectable")
	assert_true(sel.all_units().size() == 5, "all_units = 4 peasants + commander")

	# register_click double-click detection.
	sel.select_only(p0)
	var first: bool = sel.register_click(p0)
	var second: bool = sel.register_click(p0)
	assert_true(not first, "first click is not a double-click")
	assert_true(second, "fast second click is a double-click")

	# Clear.
	sel.clear()
	assert_true(sel.count() == 0, "clear empties the selection")

	# Context routing helpers exist on the managers.
	var res := ResourceNodes.new()
	add_child(res)
	res.setup(world.shard)
	var rng := RandomNumberGenerator.new()
	rng.seed = 5
	res.scatter(rng, 30)
	var bmgr := BuildingsManager.new()
	add_child(bmgr)
	bmgr.setup(world.shard)
	Events.add_resource(&"player", &"wood", 100)
	Events.add_resource(&"player", &"stone", 100)
	var site: ConstructionSite = bmgr.place(&"house", Vector3i(50, 0, 50), &"player")
	assert_true(bmgr.site_near(Vector3(50, 0, 50), 4.0) == site, "site_near finds the placed site")
	assert_true(bmgr.site_near(Vector3(90, 0, 90), 4.0) == null, "site_near null far away")

	finish()
