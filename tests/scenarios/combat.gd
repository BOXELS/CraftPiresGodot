extends ScenarioBase
## Combat: two opposing soldiers close, fight, and one kills the other; armor
## reduces damage; separation keeps them from stacking.

func _init() -> void:
	scenario_name = &"combat"

func setup() -> void:
	var world := WorldBuilder.new()
	add_child(world)
	world.build(12345)
	Sim.start_sim(12345)

	var combat := CombatManager.new()
	add_child(combat)
	combat.setup(world.shard)

	var a: Soldier = combat.spawn_soldier(Vector3(60, 0, 60), 0, &"player", "stone")
	var b: Soldier = combat.spawn_soldier(Vector3(63, 0, 60), 1, &"enemy", "wood")
	await get_tree().physics_frame
	assert_true(combat.alive_count() == 2, "two soldiers alive at start")

	# Lower b's HP so the fight resolves quickly.
	b.health.hp = 30
	var died: Array = [false]
	b.died_soldier.connect(func(_s: Soldier) -> void: died[0] = true)

	# Run until b dies (a should win: better tier = more armor/hp).
	for i in 2000:
		await get_tree().physics_frame
		if died[0]:
			break
	assert_true(died[0], "weaker soldier died in combat")
	assert_true(combat.alive_count() == 1, "one soldier remains alive")
	assert_true(a.health.is_alive(), "stronger soldier survived")

	# Armor check: raw 12 vs armor 2 -> 10 actual.
	var h := Health.new(50, 2)
	var dealt: int = h.take_damage(12)
	assert_true(dealt == 10, "armor reduces damage (dealt %d)" % dealt)
	Sim.stop_sim()
	finish()
