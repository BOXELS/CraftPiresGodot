class_name Population
extends Node
## AoE2 population: a cap from base + Keep + completed houses (age ceiling), and
## homestead spawning — completed houses slowly birth peasants, costing food from
## the settlement stock. Tracks per-house spawn state and a per-house rally point.

signal population_changed(used: int, cap: int)
signal peasant_born(peasant: Peasant, house: Dictionary)

const POP_BASE: int = 10
const POP_KEEP_BONUS: int = 5
const POP_PER_HOUSE: int = 5
const AGE_CAPS: Array = [30, 50, 75]           # Primitive / Metal / Gunpowder
const HOUSE_SPAWN_MAX: int = 5                  # lifetime births per house
const HOUSE_SPAWN_INTERVAL: float = 20.0        # seconds between births
const SPAWN_FOOD_COST: int = 25

var civ_id: StringName = &"player"
var units: UnitManager
var age: AgeManager

# Completed houses: { "pos": Vector3, "rally": Vector3, "spawns": int, "timer": float }
var houses: Array = []
var _world: WorldBuilder

func setup(p_units: UnitManager, p_age: AgeManager, p_world: WorldBuilder, p_civ: StringName = &"player") -> void:
	units = p_units
	age = p_age
	_world = p_world
	civ_id = p_civ

func used() -> int:
	var n: int = 0
	for p in units.peasants:
		if is_instance_valid(p) and p.civ_id == civ_id:
			n += 1
	return n

func cap() -> int:
	var age_idx: int = clampi(age.age if age != null else 0, 0, AGE_CAPS.size() - 1)
	var from_housing: int = POP_BASE + POP_KEEP_BONUS + houses.size() * POP_PER_HOUSE
	return mini(AGE_CAPS[age_idx], from_housing)

## Register a completed house so it raises the cap and can birth peasants.
func add_house(pos: Vector3) -> void:
	houses.append({"pos": pos, "rally": pos + Vector3(2.5, 0, 2.5), "spawns": 0, "timer": HOUSE_SPAWN_INTERVAL})
	population_changed.emit(used(), cap())

func set_rally(index: int, rally: Vector3) -> void:
	if index >= 0 and index < houses.size():
		houses[index]["rally"] = rally

func _process(delta: float) -> void:
	if not Sim.running:
		return
	for h in houses:
		if int(h["spawns"]) >= HOUSE_SPAWN_MAX:
			continue
		if used() >= cap():
			continue
		if Events.get_amount(civ_id, &"food") < SPAWN_FOOD_COST:
			continue
		h["timer"] = float(h["timer"]) - delta
		if float(h["timer"]) <= 0.0:
			h["timer"] = HOUSE_SPAWN_INTERVAL
			_spawn(h)

func _spawn(h: Dictionary) -> void:
	if not Events.spend(civ_id, {&"food": SPAWN_FOOD_COST}):
		return
	h["spawns"] = int(h["spawns"]) + 1
	var rally: Vector3 = h["rally"]
	var gy: int = _world.shard.get_height(int(rally.x), int(rally.z)) if _world != null else int(rally.y)
	var spawn_pos := Vector3(rally.x, gy, rally.z)
	var p: Peasant = units.spawn_peasant(spawn_pos, 0, civ_id)
	population_changed.emit(used(), cap())
	peasant_born.emit(p, h)
