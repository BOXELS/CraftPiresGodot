extends ScenarioBase
## Animals wander, get hunted for food; kills drop piles; peasants haul piles.

func _init() -> void:
	scenario_name = &"hunt"

func setup() -> void:
	var world := WorldBuilder.new()
	add_child(world)
	world.build(12345)
	await get_tree().physics_frame

	var units := UnitManager.new()
	add_child(units)
	units.setup(world.shard, world)

	var animals := AnimalField.new()
	add_child(animals)
	animals.setup(world.shard)
	var rng := RandomNumberGenerator.new()
	rng.seed = 7
	animals.scatter(rng, 30)
	assert_true(animals.alive_count() > 0, "animals scattered on grass")

	var piles := PileField.new()
	add_child(piles)
	piles.setup(world.shard)
	animals.animal_killed.connect(func(pos: Vector3, food: int): piles.drop(pos, &"food", food))

	# Nearest-animal query.
	var a0: Vector3 = animals.animal_pos(0)
	assert_true(animals.nearest_animal(a0, 2.0) == 0, "nearest_animal finds index 0")
	assert_true(animals.nearest_animal(Vector3(200, 0, 200), 2.0) == -1, "no animal far away")

	# Damage → kill → drops food + a pile.
	var idx: int = 0
	var food: int = 0
	food = animals.damage(idx, 1)
	assert_true(food == 0 and animals.is_alive(idx), "first hit wounds, no food yet")
	food = animals.damage(idx, 1)
	assert_true(food > 0 and not animals.is_alive(idx), "second hit kills, drops food")
	assert_true(piles.pile_count() == 1, "kill dropped a food pile")
	assert_true(piles.pile_kind(0) == &"food", "pile is food")

	# Peasant picks up the pile and it depletes.
	var take: int = piles.take(0, 10)
	assert_true(take == 10, "took 10 from pile")
	assert_true(piles.pile_amount(0) == 10, "pile has 10 left")
	piles.take(0, 99)
	assert_true(piles.pile_amount(0) == 0, "pile depleted")
	assert_true(piles.pile_count() == 0, "empty pile removed")

	# Hunt order routes through the brain (kills a fresh animal over frames).
	Sim.start_sim(4242)
	var prey: int = animals.nearest_animal(Vector3(animals.animal_pos(1).x, 0, animals.animal_pos(1).z), 3.0)
	if prey < 0:
		prey = 1
	var p: Peasant = units.spawn_peasant(animals.animal_pos(prey) + Vector3(0.5, 0, 0.5), 0)
	p.order_hunt(animals, prey)
	assert_true(p.brain.order == &"hunt", "hunt order set")
	# Step frames so the peasant walks + attacks until the kill.
	var killed: bool = false
	for i in 400:
		await get_tree().physics_frame
		if not animals.is_alive(prey):
			killed = true
			break
	assert_true(killed, "peasant hunted the animal to death")
	Sim.stop_sim()

	finish()
