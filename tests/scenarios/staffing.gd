extends ScenarioBase
## Staffing: build speed scales with worker count (diminishing returns), and
## a site only progresses while at least one worker is present.

func _init() -> void:
	scenario_name = &"staffing"

func setup() -> void:
	var world := WorldBuilder.new()
	add_child(world)
	world.build(12345)
	Sim.start_sim(12345)

	var buildings := BuildingsManager.new()
	add_child(buildings)
	buildings.setup(world.shard)

	# Fully-stock a site so build_tick is gated only by workers.
	var site := buildings.place(&"watchtower", Vector3i(70, 0, 70), &"player")
	for k in site.bom.keys():
		site.deliver(k, int(site.bom[k]))
	assert_true(site.is_fully_stocked(), "site pre-stocked for staffing test")

	# No workers -> no progress.
	var p0: float = site.progress_fraction()
	for i in 60:
		await get_tree().physics_frame
	assert_true(site.progress_fraction() == p0, "no progress without workers")

	# Add workers -> progress; 4 workers beat 1 worker's rate.
	var mgr := UnitManager.new()
	add_child(mgr)
	mgr.setup(world.shard)
	var one := mgr.spawn_peasant(Vector3(72, 0, 72), 0)
	site.add_worker(one)
	assert_true(site.worker_speed_multiplier() == 1.0, "1 worker = 1.0x")
	var more: Array = [one]
	for i in 3:
		more.append(mgr.spawn_peasant(Vector3(73 + i, 0, 72), 0))
		site.add_worker(more[i + 1])
	assert_true(site.worker_speed_multiplier() == 2.5, "4 workers = 2.5x diminishing returns")
	assert_true(site.workers.size() == 4, "site tracks 4 workers")
	Sim.stop_sim()
	finish()
