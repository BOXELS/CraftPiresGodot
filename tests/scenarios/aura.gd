extends ScenarioBase
## Spatial hash separation: two peasants spawned overlapping get pushed apart.

func _init() -> void:
	scenario_name = &"aura"

func setup() -> void:
	var world := WorldBuilder.new()
	add_child(world)
	world.build(12345)
	Sim.start_sim(12345)

	var mgr := UnitManager.new()
	add_child(mgr)
	mgr.setup(world.shard)
	var sx: int = 60
	var sz: int = 60
	var base := Vector3(sx + 0.5, world.shard.get_height(sx, sz), sz + 0.5)
	var a := mgr.spawn_peasant(base, 0)
	var b := mgr.spawn_peasant(base + Vector3(0.2, 0, 0.2), 0)  # overlapping
	await get_tree().physics_frame

	var start_dist: float = Vector2(a.position.x - b.position.x, a.position.z - b.position.z).length()
	# Let separation run over several ticks (units stay idle otherwise).
	for i in 120:
		await get_tree().physics_frame
	var end_dist: float = Vector2(a.position.x - b.position.x, a.position.z - b.position.z).length()
	assert_true(end_dist > start_dist,
		"separation pushed overlapping peasants apart (%.2f -> %.2f)" % [start_dist, end_dist])
	assert_true(mgr.peasant_count() == 2, "unit manager tracks both peasants")
	Sim.stop_sim()
	finish()
