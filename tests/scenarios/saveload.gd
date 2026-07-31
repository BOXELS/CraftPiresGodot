extends ScenarioBase
## Save/load: the shard (columns + heights) and resources round-trip through
## SaveGame JSON, and a terraform edit survives the save→load cycle.

func _init() -> void:
	scenario_name = &"saveload"

func setup() -> void:
	var world := WorldBuilder.new()
	add_child(world)
	world.build(4242)
	var mgr := UnitManager.new()
	add_child(mgr)
	mgr.setup(world.shard, world)
	await get_tree().physics_frame

	Events.reset()
	Events.add_resource(&"player", &"wood", 77)

	# Make an edit so we can tell the save apart from a fresh generate.
	world.dig(60, 60, 5)
	var h_after_dig: int = world.shard.get_height(60, 60)

	assert_true(SaveGame.save(world, mgr, 4242), "save writes without error")
	assert_true(SaveGame.has_save(), "save file exists")

	# Mutate world further, then restore from save and confirm the edit returns.
	world.raise(60, 60, 3, 3)
	var data: Dictionary = SaveGame.load_save()
	assert_true(int(data.get("seed", 0)) == 4242, "seed persisted")
	world.shard.restore(data.get("heights", []), data.get("columns", []))
	assert_true(world.shard.get_height(60, 60) == h_after_dig, "terrain edit restored from save")

	SaveGame.apply_resources(data)
	assert_true(Events.get_amount(&"player", &"wood") == 77, "resources restored")

	# Peasant state packed.
	var peas: Array = data.get("peasants", [])
	assert_true(peas.size() == mgr.peasants.size(), "peasant count persisted")
	finish()
