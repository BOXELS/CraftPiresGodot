extends ScenarioBase
## Spatial hash neighbor queries + separation strength. Placeholder for the
## commander bodyslam charge; verifies the separation math scales with overlap.

func _init() -> void:
	scenario_name = &"bodyslam"

func setup() -> void:
	var hash := SpatialHash.new(2.0)
	var world := WorldBuilder.new()
	add_child(world)
	world.build(12345)

	var mgr := UnitManager.new()
	add_child(mgr)
	mgr.setup(world.shard)
	var sx: int = 80
	var sz: int = 80
	var center := Vector3(sx + 0.5, world.shard.get_height(sx, sz), sz + 0.5)
	var a := mgr.spawn_peasant(center, 0)
	var b := mgr.spawn_peasant(center + Vector3(0.5, 0, 0), 0)
	var far := mgr.spawn_peasant(center + Vector3(20, 0, 0), 0)

	hash.clear()
	hash.insert(a)
	hash.insert(b)
	hash.insert(far)
	var near_neighbors: Array = hash.neighbors(a.position, 2.0)
	assert_true(near_neighbors.size() == 2, "neighbors finds only the 2 close peasants (got %d)" % near_neighbors.size())

	var push: Vector3 = hash.separation(a, 1.2, 0.5)
	assert_true(push.length() > 0.0, "separation produces a push for overlapping units")
	# a is at center; b is at center+0.5x. Push on a must point toward -x (away from b).
	assert_true(push.x < 0.0, "push points away from the overlapping neighbor")
	finish()
