class_name AIOpponent
extends RefCounted
## A scripted enemy civ (Phase 10). Runs a simple deterministic build→gather→
## army→attack loop on the Sim tick against a target civ. Not a neural net — a
## prioritized behavior set, seeded, so multiplayer replays stay reproducible.

var civ_id: StringName = &"enemy"
var target_civ: StringName = &"player"

var world: WorldBuilder
var units: UnitManager
var combat: CombatManager
var buildings: BuildingsManager
var depot: StorageDepot
var home: Vector3 = Vector3.ZERO
var rng: RandomNumberGenerator

var _tick_count: int = 0
var _attack_sent: bool = false

func _init(p_world: WorldBuilder, p_units: UnitManager, p_combat: CombatManager,
		p_buildings: BuildingsManager, p_depot: StorageDepot, p_home: Vector3, seed_value: int) -> void:
	world = p_world
	units = p_units
	combat = p_combat
	buildings = p_buildings
	depot = p_depot
	home = p_home
	rng = RandomNumberGenerator.new()
	rng.seed = seed_value

func setup_economy(peasant_count: int = 3, soldier_count: int = 2) -> void:
	# Starting workforce near home.
	for i in peasant_count:
		var px: float = home.x + 1.5 * float(i % 2)
		var pz: float = home.z + 1.5 * float(i / 2)
		var gy: int = world.shard.get_height(int(px), int(pz))
		var p := units.spawn_peasant(Vector3(px, gy, pz), 1, civ_id)
		p.set_meta("home", home)
		# Put them on a wood-gather standing order near home.
		p.order_gather(home + Vector3(6, 0, 0), &"wood")
	for i in soldier_count:
		var sx: float = home.x - 2.0 - float(i)
		var sz: float = home.z + float(i)
		var gy: int = world.shard.get_height(int(sx), int(sz))
		combat.spawn_soldier(Vector3(sx, gy, sz), 1, civ_id, "stone")

## Called on each Sim tick. Simple scripted priorities:
## 1. Keep peasants gathering. 2. Build a house once affordable.
## 3. Once we have 3+ soldiers, send an attack wave at the player's base.
func tick(player_base: Vector3) -> void:
	_tick_count += 1
	# Re-issue gather to idle peasants occasionally.
	if _tick_count % 40 == 0:
		for p in units.peasants:
			if is_instance_valid(p) and p.civ_id == civ_id and p.brain.order == &"idle":
				p.order_gather(home + Vector3(6, 0, 0), &"wood")
	# Build a house once we can afford it (one-time).
	if _tick_count == 120 and Events.can_afford(civ_id, BuildingDefs.bom(&"house")):
		var t := Vector3i(int(home.x) + 4, 0, int(home.z) + 4)
		Events.spend(civ_id, BuildingDefs.bom(&"house"))
		buildings.place(&"house", t, civ_id)
	# Train soldiers as resources allow (cheap: wood+stone).
	if _tick_count % 100 == 0 and combat.soldiers_for(civ_id).size() < 5:
		if Events.spend(civ_id, {&"wood": 10, &"stone": 5}):
			var gy: int = world.shard.get_height(int(home.x), int(home.z))
			combat.spawn_soldier(Vector3(home.x, gy, home.z), 1, civ_id, "stone")
	# Attack wave once we have a squad.
	if not _attack_sent and combat.soldiers_for(civ_id).size() >= 3:
		_attack_sent = true
		for s in combat.soldiers_for(civ_id):
			s.order_attack_move(player_base)

func soldiers() -> Array:
	return combat.soldiers_for(civ_id)
