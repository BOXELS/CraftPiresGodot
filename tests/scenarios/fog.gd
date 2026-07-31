extends ScenarioBase
## Fog of war: units reveal a radius; visible demotes to explored when the
## source leaves; unexplored tiles are hidden.

func _init() -> void:
	scenario_name = &"fog"

func setup() -> void:
	var fog := FogOfWar.new(&"player")
	assert_true(not fog.is_visible(64, 64), "center starts unexplored")
	assert_true(fog.explored_count() == 0, "nothing explored at start")

	# A unit at (64,64) reveals radius 6.
	fog.reveal(64, 64, 6)
	assert_true(fog.is_visible(64, 64), "center visible after reveal")
	assert_true(fog.is_visible(70, 64), "tile inside radius visible")
	assert_true(not fog.is_visible(80, 64), "tile outside radius hidden")
	assert_true(fog.visible_count() > 0, "some tiles visible")

	# Next tick with no sources: visible demotes to explored (remembered, dim).
	fog.refresh_visibility([])
	assert_true(not fog.is_visible(64, 64), "center no longer visible without source")
	assert_true(fog.is_explored(64, 64), "center stays explored (remembered)")

	# Re-reveal from a moving source updates.
	fog.refresh_visibility([{"x": 20, "z": 20, "radius": 5}])
	assert_true(fog.is_visible(20, 20), "new source tile visible")
	assert_true(fog.is_explored(64, 64), "old area still explored")
	finish()
