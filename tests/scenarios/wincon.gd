extends ScenarioBase
## Win conditions: conquest eliminates a civ with no commander+soldiers; the last
## civ standing wins; prestige scoring crosses the threshold.

func _init() -> void:
	scenario_name = &"wincon"

func setup() -> void:
	var wc := WinConditions.new()
	wc.register(&"player")
	wc.register(&"enemy")

	# Both alive; no winner yet.
	assert_true(wc.winner() == &"", "no winner while both alive")

	# Enemy loses everything -> eliminated -> player wins by conquest.
	var defeated: StringName = wc.check_conquest(&"enemy", false, 0)
	assert_true(defeated == &"enemy", "enemy eliminated with no forces")
	assert_true(not wc.is_alive(&"enemy"), "enemy marked dead")
	assert_true(wc.winner() == &"player", "player wins by conquest")

	# Prestige: build + tech + age pushes a fresh civ over threshold.
	var wc2 := WinConditions.new()
	wc2.prestige_threshold = 12
	wc2.register(&"player")
	for i in 3:
		wc2.record_building(&"player")
	for i in 1:
		wc2.record_tech(&"player")
	wc2.set_age(&"player", 2)
	var score: int = wc2.prestige_score(&"player")
	assert_true(score >= 12, "prestige score reaches threshold (got %d)" % score)
	var won_flag: Array = [false]
	wc2.civ_won.connect(func(_c: StringName, _cond: StringName) -> void: won_flag[0] = true)
	assert_true(wc2.check_prestige(&"player"), "prestige win triggers")
	assert_true(won_flag[0], "civ_won signal emitted")
	finish()
