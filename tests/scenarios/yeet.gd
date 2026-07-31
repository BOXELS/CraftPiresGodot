extends ScenarioBase
## Tumble/ragdoll cycle: a peasant launched airborne enters TUMBLE mode and
## recovers to IDLE on land. Exercises the silly_physics airborne path.

func _init() -> void:
	scenario_name = &"yeet"

func setup() -> void:
	var world := WorldBuilder.new()
	add_child(world)
	world.build(12345)
	Sim.start_sim(12345)

	var mgr := UnitManager.new()
	add_child(mgr)
	mgr.setup(world.shard)
	var sx: int = 70
	var sz: int = 70
	var p := mgr.spawn_peasant(Vector3(sx + 0.5, world.shard.get_height(sx, sz), sz + 0.5), 0)
	await get_tree().physics_frame

	# Launch airborne.
	p.anim.set_airborne(Vector3(2.0, 6.0, 1.0))
	assert_true(p.anim.mode == SillyPhysics.Mode.TUMBLE, "set_airborne enters TUMBLE mode")
	# Simulate the tumble for a few frames, then land.
	for i in 30:
		await get_tree().physics_frame
	p.anim.land(p.rig)
	assert_true(p.anim.mode == SillyPhysics.Mode.IDLE, "land() returns peasant to IDLE")
	assert_true(p.rig.rotation == Vector3.ZERO, "rig rotation reset after land")
	Sim.stop_sim()
	finish()
