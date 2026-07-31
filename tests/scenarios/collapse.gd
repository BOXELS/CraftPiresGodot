extends ScenarioBase
## Collapse physics: digging out from under an overhang makes the unsupported
## blocks fall; laterally-supported blocks stay put.

func _init() -> void:
	scenario_name = &"collapse"

func setup() -> void:
	var world := WorldBuilder.new()
	add_child(world)
	world.build(12345)
	await get_tree().physics_frame

	# Build a small floating platform: raise a 3x3 pad high, then hollow out
	# beneath the center so part floats with no support.
	var cx: int = 50
	var cz: int = 50
	# Raise a column to y+3, then remove the middle so the top floats.
	world.raise(cx, cz, 3, 3)
	var h0: int = world.shard.get_height(cx, cz)
	# Dig directly under the top block to create a floating cap.
	# (raise added 3 on top; dig removes from the top down, so dig 1 leaves cap
	# supported. Instead manually zero a mid block to force a float.)
	var top: int = h0 - 1
	world.shard.set_material(cx, top - 1, cz, 0)   # remove support beneath top
	world.shard.set_material(cx, top - 2, cz, 0)
	# Now top floats 2 above the column base with a gap. Settle should drop it.
	var before_gap: int = world.shard.get_material(cx, top, cz)
	assert_true(before_gap != 0, "cap block present before settle")
	var fell: int = world.settle(cx, cz, 0)
	assert_true(fell > 0, "settle moved the floating cap (fell=%d)" % fell)
	# After settling, no vertical gap directly under a solid block remains here.
	var h1: int = world.shard.get_height(cx, cz)
	var gap_found: bool = false
	for y in range(1, h1):
		if world.shard.get_material(cx, y, cz) != 0 and world.shard.get_material(cx, y - 1, cz) == 0:
			gap_found = true
	assert_true(not gap_found, "no floating gap remains after settle")
	finish()
