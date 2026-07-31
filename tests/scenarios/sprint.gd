extends ScenarioBase
## Peasant order_move reaches target via the task brain + Sim tick.

func _init() -> void:
	scenario_name = &"sprint"

func setup() -> void:
	var world := WorldBuilder.new()
	add_child(world)
	world.build(12345)
	Sim.start_sim(12345)

	var mgr := UnitManager.new()
	add_child(mgr)
	mgr.setup(world.shard)
	var sx: int = 40
	var sz: int = 40
	var p := mgr.spawn_peasant(Vector3(sx + 0.5, world.shard.get_height(sx, sz), sz + 0.5), 0)
	await get_tree().physics_frame

	var target := Vector3(sx + 5.5, 0, sz + 0.5)
	target.y = world.shard.get_height(int(target.x), int(target.z))
	p.order_move(target)
	assert_true(p.brain.order == &"move", "order_move set on brain")

	var arrived_flag: Array = [false]
	p.arrived.connect(func() -> void: arrived_flag[0] = true)
	for i in 600:
		await get_tree().physics_frame
		if arrived_flag[0] or p.brain.order == &"idle":
			break
	assert_true(arrived_flag[0], "peasant arrived at move target")
	assert_true(p.brain.order == &"idle", "brain returned to standing idle after move")
	Sim.stop_sim()
	finish()
