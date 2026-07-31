extends ScenarioBase
## Click-to-move: commander reaches the ordered position and stops.

func _init() -> void:
	scenario_name = &"mine"

func setup() -> void:
	var world := WorldBuilder.new()
	add_child(world)
	world.build(12345)

	var cmd := Commander.new()
	add_child(cmd)
	cmd.setup(world.shard, 0)
	var sx: int = 30
	var sz: int = 30
	cmd.position = Vector3(sx + 0.5, world.shard.get_height(sx, sz), sz + 0.5)

	var target := Vector3(sx + 6.5, 0, sz + 6.5)
	target.y = world.shard.get_height(int(target.x), int(target.z))
	await get_tree().physics_frame  # let body enter physics space
	cmd.order_move(target)
	assert_true(cmd.has_target, "move order set")

	var arrived_flag: Array = [false]
	cmd.arrived.connect(func() -> void: arrived_flag[0] = true)
	for i in 600:
		await get_tree().physics_frame
		if arrived_flag[0]:
			break
	assert_true(arrived_flag[0], "commander arrived at move target")
	var dist: float = Vector2(cmd.position.x - target.x, cmd.position.z - target.z).length()
	assert_true(dist < 0.5, "commander stopped near target (dist %.2f)" % dist)

	finish()
