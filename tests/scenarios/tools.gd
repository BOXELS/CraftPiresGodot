extends ScenarioBase
## Tools: crafting spends resources through Events, gated by affordability, and
## the right tool speeds up the matching task kind.

func _init() -> void:
	scenario_name = &"tools"

func setup() -> void:
	Events.reset()
	# Not enough resources -> cannot craft.
	assert_true(not Tools.can_craft(&"player", &"pick"), "cannot craft pick without resources")

	Events.add_resource(&"player", &"wood", 20)
	Events.add_resource(&"player", &"stone", 20)
	assert_true(Tools.can_craft(&"player", &"pick"), "can craft pick when stocked")

	var wood0: int = Events.get_amount(&"player", &"wood")
	var stone0: int = Events.get_amount(&"player", &"stone")
	assert_true(Tools.craft(&"player", &"pick"), "craft pick succeeds")
	assert_true(Events.get_amount(&"player", &"wood") == wood0 - 2, "pick cost 2 wood")
	assert_true(Events.get_amount(&"player", &"stone") == stone0 - 4, "pick cost 4 stone")

	# Effect matching.
	assert_true(Tools.effect_multiplier(&"pick", &"stone") == 1.5, "pick speeds stone")
	assert_true(Tools.effect_multiplier(&"pick", &"wood") == 1.0, "pick does not speed wood")
	assert_true(Tools.effect_multiplier(&"hammer", &"build") > 1.0, "hammer speeds build")
	finish()
