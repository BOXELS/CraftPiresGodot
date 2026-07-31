extends ScenarioBase
## Commander click-to-move + beam-gather. Runs headless: builds world, spawns
## commander, issues orders, steps physics, asserts cargo and digging happened.

func _init() -> void:
	scenario_name = &"beam"

func setup() -> void:
	var world := WorldBuilder.new()
	add_child(world)
	world.build(12345)

	var cmd := Commander.new()
	add_child(cmd)
	cmd.setup(world.shard, 0)
	var sx: int = 20
	var sz: int = 20
	cmd.position = Vector3(sx + 0.5, world.shard.get_height(sx, sz), sz + 0.5)
	assert_true(cmd.rig != null, "commander rig built")

	# Order a beam gather a few tiles away.
	var tx: int = sx + 3
	var tz: int = sz
	var target := Vector3(tx + 0.5, world.shard.get_height(tx, tz), tz + 0.5)
	var h_before: int = world.shard.get_height(tx, tz)
	Events.reset()
	await get_tree().physics_frame
	cmd.order_beam_gather(target)
	assert_true(cmd.beaming, "beam order engaged")

	# Run ~8 seconds of real physics frames (gather ticks fire during beaming).
	for i in 480:
		await get_tree().physics_frame
		if cmd.cargo > 0:
			break
	assert_true(cmd.cargo > 0, "beam gathered cargo (got %d)" % cmd.cargo)
	assert_true(world.shard.get_height(tx, tz) < h_before, "beam mined the column down")
	assert_true(Events.get_amount(&"player", &"stone") > 0, "resource funnel credited stone")

	# Deposit empties cargo.
	var had: int = cmd.cargo
	var deposited: int = cmd.deposit_at_keep()
	assert_true(deposited == had, "deposit returns gathered amount")
	assert_true(cmd.cargo == 0, "deposit empties cargo")

	finish()
