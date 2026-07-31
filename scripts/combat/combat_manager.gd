class_name CombatManager
extends Node3D
## Owns soldiers per civ, registers combatants for target scanning, and applies
## spatial separation so melee units don't stack. Siege damage to buildings goes
## through attack_building.

const SEPARATION_RADIUS: float = 1.2
const SEPARATION_STRENGTH: float = 0.5

var shard: VoxelShard
var soldiers: Array = []
var _hash := SpatialHash.new(2.0)

func setup(p_shard: VoxelShard) -> void:
	shard = p_shard

func spawn_soldier(pos: Vector3, team: int = 0, civ: StringName = &"player", tier: String = "stone") -> Soldier:
	var s := Soldier.new()
	add_child(s)
	s.setup(shard, team, tier)
	s.civ_id = civ
	s.position = pos
	s.guard_post = pos
	s.add_to_group("combatants")
	s.died_soldier.connect(_on_soldier_died)
	soldiers.append(s)
	return s

func _ready() -> void:
	if not Sim.tick.is_connected(_on_tick):
		Sim.tick.connect(_on_tick)

func _on_tick(_i: int) -> void:
	# Rebuild spatial hash and separate soldiers.
	_hash.clear()
	for s in soldiers:
		if is_instance_valid(s) and s.health.is_alive():
			_hash.insert(s)
	for s in soldiers:
		if not is_instance_valid(s) or not s.health.is_alive():
			continue
		var push: Vector3 = _hash.separation(s, SEPARATION_RADIUS, SEPARATION_STRENGTH)
		if push.length() > 0.001:
			s.position += push * Sim.TICK_INTERVAL

func _on_soldier_died(s: Soldier) -> void:
	soldiers.erase(s)

func soldiers_for(civ: StringName) -> Array:
	var out: Array = []
	for s in soldiers:
		if is_instance_valid(s) and s.civ_id == civ and s.health.is_alive():
			out.append(s)
	return out

## Siege: damage a building site. Buildings have HP via their own Health; here
## we route soldier damage to a ConstructionSite's structure pool.
func attack_building(site: ConstructionSite, damage: int) -> int:
	if not is_instance_valid(site):
		return 0
	# Sites expose take_damage via meta Health (set when placed).
	var h: Variant = site.get_meta("health", null)
	if h is Health:
		return (h as Health).take_damage(damage)
	return 0

func alive_count() -> int:
	var n: int = 0
	for s in soldiers:
		if is_instance_valid(s) and s.health.is_alive():
			n += 1
	return n
