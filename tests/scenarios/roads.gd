extends ScenarioBase
## Dirt roads: pave grass/dirt, spend dirt stock, give move-speed bonus.

func _init() -> void:
	scenario_name = &"roads"

func setup() -> void:
	var world := WorldBuilder.new()
	add_child(world)
	world.build(12345)
	await get_tree().physics_frame

	# Find a grass cell near home.
	var gx: int = 40
	var gz: int = 40
	for r in 20:
		var found: bool = false
		for dx in range(-r, r + 1):
			for dz in range(-r, r + 1):
				var x: int = 40 + dx
				var z: int = 40 + dz
				if world.shard.surface_material(x, z) == 1:
					gx = x
					gz = z
					found = true
					break
			if found:
				break
		if found:
			break
	assert_true(MaterialInteractions.can_pave_dirt_road(1), "grass is paveable")
	assert_true(MaterialInteractions.can_pave_dirt_road(2), "dirt is paveable")
	assert_true(not MaterialInteractions.can_pave_dirt_road(3), "stone is not paveable")
	assert_true(not MaterialInteractions.can_pave_dirt_road(MaterialInteractions.ROAD_DIRT), "already-road not re-paveable")

	Events.add_resource(&"player", &"dirt", 20)
	assert_true(world.pave_dirt_road(gx, gz), "pave succeeds on grass")
	assert_true(world.shard.surface_material(gx, gz) == MaterialInteractions.ROAD_DIRT, "surface is road")
	assert_true(not world.pave_dirt_road(gx, gz), "re-pave same tile is a no-op")

	# Move multiplier: road dry = 1.35, muddy road = mud slow.
	assert_true(is_equal_approx(MaterialInteractions.move_multiplier(0, MaterialInteractions.ROAD_DIRT), 1.35), "road bonus 1.35×")
	assert_true(is_equal_approx(MaterialInteractions.move_multiplier(0, 1), 1.0), "grass is 1.0×")
	assert_true(MaterialInteractions.move_multiplier(2, MaterialInteractions.ROAD_DIRT) < 1.0, "wet road slows")

	# MenuController paint spends dirt.
	var units := UnitManager.new()
	add_child(units)
	units.setup(world.shard, world)
	var menu := MenuController.new()
	add_child(menu)
	menu.setup(world, units, null, null, null, null)
	await get_tree().process_frame
	menu.arm_pave()
	assert_true(menu.pending_pave, "pave mode armed")
	# Neighbor grass cell.
	var nx: int = gx + 1
	var nz: int = gz
	if not MaterialInteractions.can_pave_dirt_road(world.shard.surface_material(nx, nz)):
		nx = gx
		nz = gz + 1
	var before: int = Events.get_amount(&"player", &"dirt")
	var ok: bool = menu.paint_road_at(Vector3(nx, 0, nz))
	if ok:
		assert_true(Events.get_amount(&"player", &"dirt") == before - MaterialInteractions.DIRT_ROAD_COST,
			"paint spends dirt stock")
		assert_true(menu.pending_pave, "pave mode stays armed after paint (improvement)")
	else:
		# Neighbor may be rock — still assert stay-armed.
		assert_true(menu.pending_pave, "pave mode stays armed even on failed paint")

	menu.cancel_pending()
	assert_true(not menu.pending_pave, "Esc/cancel clears pave mode")

	finish()
