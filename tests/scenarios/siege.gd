extends ScenarioBase
## Siege: soldier damage routes through CombatManager.attack_building into a
## building's Health pool; enough damage destroys the structure.

func _init() -> void:
	scenario_name = &"siege"

func setup() -> void:
	var world := WorldBuilder.new()
	add_child(world)
	world.build(12345)
	var combat := CombatManager.new()
	add_child(combat)
	combat.setup(world.shard)

	# Place a building and give it a structural Health pool.
	var buildings := BuildingsManager.new()
	add_child(buildings)
	buildings.setup(world.shard)
	var site: ConstructionSite = buildings.place(&"house", Vector3i(60, 0, 60), &"enemy")
	var hp := Health.new(100, 0)
	site.set_meta("health", hp)
	assert_true(combat.attack_building(site, 30) == 30, "siege damage applied")
	assert_true(hp.hp == 70, "building hp reduced by siege")

	# Destroy it.
	var destroyed: Array = [false]
	hp.died.connect(func() -> void: destroyed[0] = true)
	combat.attack_building(site, 100)
	assert_true(destroyed[0], "building destroyed at 0 hp")
	finish()
