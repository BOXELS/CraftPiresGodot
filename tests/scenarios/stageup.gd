extends ScenarioBase
## Stage progression: carry capacity, move speed, and work speed rise with
## PeasantStage; outfit tier changes; work_speed multiplies with tools.

func _init() -> void:
	scenario_name = &"stageup"

func setup() -> void:
	var world := WorldBuilder.new()
	add_child(world)
	world.build(12345)
	var mgr := UnitManager.new()
	add_child(mgr)
	mgr.setup(world.shard, world)
	var p := mgr.spawn_peasant(Vector3(10, 0, 10), 0)
	await get_tree().physics_frame

	# Primitive baseline.
	assert_true(p.carry_capacity() == 10, "primitive carry = 10")
	assert_true(is_equal_approx(p.move_speed(), 2.6), "primitive speed = 2.6")
	assert_true(is_equal_approx(p.work_speed(), 1.0), "primitive work = 1.0")

	# Advance to Wheel stage.
	p.set_stage(PeasantStage.Stage.WHEEL)
	assert_true(p.carry_capacity() == 50, "wheel carry = 50")
	assert_true(p.move_speed() > 2.6, "wheel speed faster")
	assert_true(p.work_speed() > 1.0, "wheel work faster")

	# Tool bonus stacks on stage work speed for the matching job.
	p.equip_tool(&"shovel")
	p.order_dig(Vector3(20, 0, 20), &"dirt")
	assert_true(p.work_speed() > PeasantStage.work(PeasantStage.Stage.WHEEL), "shovel boosts dig work speed")
	finish()
