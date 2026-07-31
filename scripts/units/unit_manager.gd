class_name UnitManager
extends Node3D
## Owns all peasants: spawns them, ticks their brains on the Sim tick, and
## applies spatial-hash separation so they don't stack. Commanders are separate.

const SEPARATION_RADIUS: float = 1.2
const SEPARATION_STRENGTH: float = 0.5

var shard: VoxelShard
var world: WorldBuilder
var peasants: Array = []
var _hash := SpatialHash.new(2.0)

func setup(p_shard: VoxelShard, p_world: WorldBuilder = null) -> void:
	shard = p_shard
	world = p_world

func spawn_peasant(pos: Vector3, team: int = 0, civ: StringName = &"player") -> Peasant:
	var p := Peasant.new()
	add_child(p)
	p.setup(shard, team)
	p.civ_id = civ
	p.world = world
	p.position = pos
	p.set_meta("home", pos)
	peasants.append(p)
	return p

func _ready() -> void:
	if not Sim.tick.is_connected(_on_tick):
		Sim.tick.connect(_on_tick)

func _on_tick(_tick_index: int) -> void:
	# Rebuild spatial hash, tick brains, then separate.
	_hash.clear()
	for p in peasants:
		if is_instance_valid(p):
			_hash.insert(p)
	for p in peasants:
		if not is_instance_valid(p):
			continue
		p.brain.tick(Sim.TICK_INTERVAL)
	for p in peasants:
		if not is_instance_valid(p):
			continue
		var push: Vector3 = _hash.separation(p, SEPARATION_RADIUS, SEPARATION_STRENGTH)
		if push.length() > 0.001:
			p.position += push * Sim.TICK_INTERVAL

func peasant_count() -> int:
	return peasants.size()
