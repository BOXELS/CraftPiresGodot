extends ScenarioBase
## Gather cycle: order_gather walks to node, fills carry, hauls to drop point,
## credits Events, and returns to keep gathering (standing order).

func _init() -> void:
	scenario_name = &"ferry"

func setup() -> void:
	var world := WorldBuilder.new()
	add_child(world)
	world.build(12345)
	Sim.start_sim(12345)
	Events.reset()

	var mgr := UnitManager.new()
	add_child(mgr)
	mgr.setup(world.shard)
	var sx: int = 50
	var sz: int = 50
	var home := Vector3(sx + 0.5, world.shard.get_height(sx, sz), sz + 0.5)
	var p := mgr.spawn_peasant(home, 0)
	await get_tree().physics_frame

	# Gather node a few tiles away; drop back at home.
	var node := Vector3(sx + 4.5, 0, sz + 0.5)
	node.y = world.shard.get_height(int(node.x), int(node.z))
	p.order_gather(node, &"wood")
	assert_true(p.brain.order == &"gather", "order_gather set")

	# Run enough frames for: walk there + gather time + walk back + deposit.
	for i in 1200:
		await get_tree().physics_frame
		if Events.get_amount(&"player", &"wood") > 0:
			break
	assert_true(Events.get_amount(&"player", &"wood") > 0,
		"gather cycle credited wood to Events (got %d)" % Events.get_amount(&"player", &"wood"))
	assert_true(p.brain.order == &"gather", "standing order keeps gathering after deposit")
	Sim.stop_sim()
	finish()
