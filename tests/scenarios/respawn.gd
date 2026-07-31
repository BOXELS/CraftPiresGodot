extends ScenarioBase
## Commander respawn: lethal damage downs the commander (rig hidden, sim holds),
## then respawns at the respawn point with full health after the timer.

func _init() -> void:
	scenario_name = &"respawn"

func setup() -> void:
	var world := WorldBuilder.new()
	add_child(world)
	world.build(12345)
	var c := Commander.new()
	add_child(c)
	c.setup(world.shard, 0)
	c.position = Vector3(64, world.shard.get_height(64, 64), 64)
	c.respawn_point = Vector3(50, world.shard.get_height(50, 50), 50)
	await get_tree().physics_frame
	assert_true(c.alive, "commander alive at start")

	var died_flag: Array = [false]
	c.commander_died.connect(func() -> void: died_flag[0] = true)
	c.health.take_damage(9999)
	assert_true(died_flag[0], "commander died on lethal damage")
	assert_true(not c.alive, "commander down after death")
	assert_true(not c.rig.visible, "rig hidden while down")

	var back: Array = [false]
	c.commander_respawned.connect(func() -> void: back[0] = true)
	# Step past the respawn timer.
	for i in 600:
		await get_tree().physics_frame
		if back[0]:
			break
	assert_true(back[0], "commander respawned after timer")
	assert_true(c.alive, "commander alive again")
	assert_true(c.health.hp == c.health.max_hp, "respawned at full health")
	assert_true(c.position.distance_to(Vector3(50, c.position.y, 50)) < 1.0, "respawned at respawn point")
	finish()
