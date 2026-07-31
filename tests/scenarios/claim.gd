extends ScenarioBase
## Territory: buildings stamp a claim radius; the Keep claims the widest; claim
## area grows as buildings are added.

func _init() -> void:
	scenario_name = &"claim"

func setup() -> void:
	var terr := Territory.new(&"player")
	assert_true(not terr.is_owned(64, 64), "nothing owned at start")
	assert_true(terr.owned_count() == 0, "owned count zero at start")

	terr.add_claim(64, 64, &"house")
	assert_true(terr.is_owned(64, 64), "house claims its tile")
	assert_true(terr.is_owned(64 + 5, 64), "house claims inside radius 6")
	assert_true(not terr.is_owned(64 + 9, 64), "house does not claim beyond radius")
	var after_house: int = terr.owned_count()

	# A Keep claims a much larger area.
	terr.add_claim(30, 30, &"keep")
	assert_true(terr.is_owned(30 + 17, 30), "keep claims inside radius 18")
	assert_true(terr.owned_count() > after_house, "claim area grows with more buildings")
	finish()
