extends ScenarioBase
## Resource scatter: trees spawn on grass, zero-art blocks, counts are sane.

func _init() -> void:
	scenario_name = &"fell"

func setup() -> void:
	var world := WorldBuilder.new()
	add_child(world)
	world.build(12345)

	var resources := ResourceNodes.new()
	add_child(resources)
	resources.setup(world.shard)
	var rng := RandomNumberGenerator.new()
	rng.seed = 777
	resources.scatter(rng, 120)

	assert_true(resources.tree_count() > 20, "trees scattered across grass (got %d)" % resources.tree_count())
	var first := resources.get_child(0) as Node3D
	assert_true(first != null, "first tree exists")
	assert_true(first.get_child_count() >= 3, "tree has trunk + canopy blocks")

	finish()
