extends ScenarioBase
## Population: cap from houses, homestead spawning costs food and respects the cap.

func _init() -> void:
	scenario_name = &"population"

func setup() -> void:
	var world := WorldBuilder.new()
	add_child(world)
	world.build(12345)
	await get_tree().physics_frame

	var units := UnitManager.new()
	add_child(units)
	units.setup(world.shard, world)
	var age := AgeManager.new(&"player")

	var pop := Population.new()
	add_child(pop)
	pop.setup(units, age, world, &"player")

	# Base cap with no houses: min(age1 cap 30, base 10 + keep 5) = 15.
	assert_true(pop.cap() == 15, "base cap 15 with no houses (got %d)" % pop.cap())
	assert_true(pop.used() == 0, "no peasants at start")

	# Spawn 3 peasants → used 3.
	for i in 3:
		units.spawn_peasant(Vector3(40.0 + i, 0, 40.0), 0)
	assert_true(pop.used() == 3, "used counts spawned peasants")

	# Add a house → cap rises by POP_PER_HOUSE.
	pop.add_house(Vector3(50, 0, 50))
	assert_true(pop.cap() == 20, "house raises cap by 5 (got %d)" % pop.cap())

	# Homestead spawning: with food, a birth fires after the interval.
	Events.add_resource(&"player", &"food", 200)
	var before: int = pop.used()
	# Force the timer to fire immediately.
	pop.houses[0]["timer"] = 0.0
	Sim.start_sim(999)
	pop._process(0.1)
	assert_true(pop.used() == before + 1, "house births a peasant when fed")
	assert_true(int(pop.houses[0]["spawns"]) == 1, "house spawn counter increments")
	assert_true(Events.get_amount(&"player", &"food") == 200 - Population.SPAWN_FOOD_COST,
		"birth spends food (got %d)" % Events.get_amount(&"player", &"food"))

	# No food → no birth.
	Events.spend(&"player", {&"food": Events.get_amount(&"player", &"food")})
	pop.houses[0]["timer"] = 0.0
	var before2: int = pop.used()
	pop._process(0.1)
	assert_true(pop.used() == before2, "no birth without food")

	# Lifetime max per house.
	pop.houses[0]["spawns"] = Population.HOUSE_SPAWN_MAX
	Events.add_resource(&"player", &"food", 500)
	pop.houses[0]["timer"] = 0.0
	var before3: int = pop.used()
	pop._process(0.1)
	assert_true(pop.used() == before3, "house stops at lifetime spawn max")

	Sim.stop_sim()
	finish()
