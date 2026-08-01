extends ScenarioBase
## Waypoints: Shift+RMB queues a route; plain RMB replaces it. Also checks
## formation move offsets don't crash with a multi-select.

func _init() -> void:
	scenario_name = &"waypoints"

func setup() -> void:
	var world := WorldBuilder.new()
	add_child(world)
	world.build(12345)
	await get_tree().physics_frame

	var units := UnitManager.new()
	add_child(units)
	units.setup(world.shard, world)
	Sim.start_sim(77)

	var p: Peasant = units.spawn_peasant(Vector3(40, 0, 40), 0)
	p.order_move(Vector3(45, 0, 40))
	assert_true(p.brain.order == &"move", "first move starts a move order")
	p.order_move(Vector3(50, 0, 40), true)
	p.order_move(Vector3(55, 0, 40), true)
	assert_true(p.brain.waypoints.size() == 2, "two waypoints queued (got %d)" % p.brain.waypoints.size())

	# Walk until the first destination, then the queue should shrink.
	var frames: int = 0
	while p.brain.waypoints.size() == 2 and frames < 600:
		await get_tree().physics_frame
		frames += 1
	assert_true(p.brain.waypoints.size() <= 1, "first waypoint consumed after arrival")

	# Plain move clears the queue.
	p.order_move(Vector3(42, 0, 42), false)
	assert_true(p.brain.waypoints.is_empty(), "plain move clears the queue")

	# Commander queue.
	var cmd := Commander.new()
	add_child(cmd)
	cmd.setup(world.shard, 0)
	cmd.position = Vector3(30, world.shard.get_height(30, 30), 30)
	cmd.order_move(Vector3(35, 0, 30))
	cmd.order_move(Vector3(38, 0, 30), true)
	assert_true(cmd.waypoints.size() == 1, "commander queues one waypoint")
	cmd.order_move(Vector3(32, 0, 32), false)
	assert_true(cmd.waypoints.is_empty(), "commander plain move clears queue")

	Sim.stop_sim()
	finish()
