extends ScenarioBase
## Mud: water on dirt/grass produces mud that slows movement; deep water slows
## more; dry stone is unaffected.

func _init() -> void:
	scenario_name = &"mud"

func setup() -> void:
	# Shallow water on grass/dirt -> mud slow.
	var m_grass: float = MaterialInteractions.move_multiplier(2, 1)
	assert_true(is_equal_approx(m_grass, MaterialInteractions.MUD_SLOW), "shallow water on grass = mud slow")
	var m_dirt: float = MaterialInteractions.move_multiplier(1, 2)
	assert_true(m_dirt < 1.0, "shallow water on dirt slows")

	# Deep water wading slows even more.
	var m_deep: float = MaterialInteractions.move_multiplier(6, 3)
	assert_true(m_deep < MaterialInteractions.MUD_SLOW, "deep water slows more than mud")

	# Dry stone is unaffected.
	var m_stone: float = MaterialInteractions.move_multiplier(0, 3)
	assert_true(is_equal_approx(m_stone, 1.0), "dry stone unaffected")
	finish()
