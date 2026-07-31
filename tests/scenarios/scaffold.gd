extends ScenarioBase
## Smoke test for Phase 0: autoloads exist, resource funnel works, seeded RNG
## is deterministic, scenario harness reports correctly.

func _init() -> void:
	scenario_name = &"scaffold"

func _ready() -> void:
	super()
	assert_true(typeof(Events) == TYPE_OBJECT, "Events autoload present")
	assert_true(typeof(Sim) == TYPE_OBJECT, "Sim autoload present")
	assert_true(typeof(Controls) == TYPE_OBJECT, "Controls autoload present")

	Events.reset()
	Events.add_resource(&"test", &"wood", 100)
	assert_true(Events.get_amount(&"test", &"wood") == 100, "add_resource credits wood")
	assert_true(Events.spend(&"test", {&"wood": 40}), "spend succeeds when affordable")
	assert_true(Events.get_amount(&"test", &"wood") == 60, "spend deducts correctly")
	assert_true(not Events.spend(&"test", {&"wood": 999}), "spend fails when not affordable")

	Sim.start_sim(12345)
	var a: int = Sim.rng.randi()
	Sim.start_sim(12345)
	var b: int = Sim.rng.randi()
	assert_true(a == b, "seeded RNG reproduces same first value")
	Sim.stop_sim()

	finish()
