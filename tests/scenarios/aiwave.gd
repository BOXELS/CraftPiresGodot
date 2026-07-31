extends ScenarioBase
## AI opponent: sets up an enemy economy (peasants gather), trains soldiers over
## time, and sends an attack wave at the player base once it has a squad.

func _init() -> void:
	scenario_name = &"aiwave"

func setup() -> void:
	var world := WorldBuilder.new()
	add_child(world)
	world.build(12345)
	Sim.start_sim(12345)
	Events.reset()
	Events.add_resource(&"enemy", &"wood", 200)
	Events.add_resource(&"enemy", &"stone", 100)

	var units := UnitManager.new()
	add_child(units)
	units.setup(world.shard, world)
	var combat := CombatManager.new()
	add_child(combat)
	combat.setup(world.shard)
	var buildings := BuildingsManager.new()
	add_child(buildings)
	buildings.setup(world.shard)
	var depot := StorageDepot.new(&"enemy")

	var home := Vector3(90, world.shard.get_height(90, 90), 90)
	var ai := AIOpponent.new(world, units, combat, buildings, depot, home, 99)
	ai.setup_economy(3, 2)
	assert_true(combat.soldiers_for(&"enemy").size() == 2, "ai starts with 2 soldiers")
	assert_true(units.peasants.size() == 3, "ai starts with 3 peasants")

	# Tick the AI; it should train toward a squad and eventually attack.
	var player_base := Vector3(64, 0, 64)
	for i in 400:
		ai.tick(player_base)
		await get_tree().physics_frame
	assert_true(ai._attack_sent, "ai sent an attack wave once it had a squad")
	assert_true(combat.soldiers_for(&"enemy").size() >= 3, "ai grew to 3+ soldiers")
	Sim.stop_sim()
	finish()
