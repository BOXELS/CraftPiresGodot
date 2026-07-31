extends ScenarioBase
## Season + Hall of Legends: time advances the season, ending archives a winner
## into the hall (persisted), and the next season starts fresh. Titles count up.

func _init() -> void:
	scenario_name = &"season"

func setup() -> void:
	# Isolate the hall file for this test so persisted entries don't leak in.
	HallOfLegends.TEST_PATH = "user://_hall_test.json"
	# Clear any leftover test hall.
	if FileAccess.file_exists(HallOfLegends.TEST_PATH):
		DirAccess.remove_absolute(HallOfLegends.TEST_PATH)
	var season := Season.new()
	season.days_per_season = 10.0
	season.seconds_per_day = 0.01  # fast for the test
	assert_true(season.season_number == 1, "starts in season 1")

	var ended: Array = [false]
	season.season_ended.connect(func(_n: int) -> void: ended[0] = true)
	# Advance past the season length.
	for i in 120:
		season.tick(0.1)
	assert_true(ended[0], "season ended after enough time")
	assert_true(season.progress() >= 1.0, "season progress full")

	# Reset archives the winner and rolls to season 2.
	var next: int = season.reset_for_next(&"player", WinConditions.CONQUEST, 42, {"kills": 7})
	assert_true(next == 2, "rolled to season 2")
	assert_true(season.elapsed_days == 0.0, "season clock reset")
	assert_true(season.hall.champions().size() == 1, "one champion inducted")
	assert_true(season.hall.titles_for(&"player") == 1, "player has one title")
	assert_true(season.hall.most_titles() == &"player", "player leads titles")

	# A second season win by the same civ racks up titles.
	season.reset_for_next(&"player", WinConditions.PRESTIGE, 55, {})
	assert_true(season.hall.titles_for(&"player") == 2, "player has two titles")
	assert_true(season.season_number == 3, "now season 3")
	finish()
