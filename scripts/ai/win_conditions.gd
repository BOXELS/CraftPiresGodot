class_name WinConditions
extends RefCounted
## Prestige + win conditions (Phase 10). A civ wins by eliminating all enemy
## commanders and soldiers (conquest) or by reaching a prestige threshold
## (buildings completed + techs researched + age). Tracks per-civ standing.

signal civ_won(civ_id: StringName, condition: StringName)

var civs: Dictionary = {}   # civ_id -> {buildings, techs, age, alive}
const CONQUEST: StringName = &"conquest"
const PRESTIGE: StringName = &"prestige"
var prestige_threshold: int = 20

func register(civ_id: StringName) -> void:
	civs[civ_id] = {"buildings": 0, "techs": 0, "age": 1, "alive": true}

func record_building(civ_id: StringName) -> void:
	if civs.has(civ_id):
		civs[civ_id]["buildings"] = int(civs[civ_id]["buildings"]) + 1

func record_tech(civ_id: StringName) -> void:
	if civs.has(civ_id):
		civs[civ_id]["techs"] = int(civs[civ_id]["techs"]) + 1

func set_age(civ_id: StringName, age: int) -> void:
	if civs.has(civ_id):
		civs[civ_id]["age"] = age

func prestige_score(civ_id: StringName) -> int:
	if not civs.has(civ_id):
		return 0
	var c: Dictionary = civs[civ_id]
	return int(c["buildings"]) * 2 + int(c["techs"]) * 3 + int(c["age"]) * 4

## Conquest: a civ with no remaining commanders or soldiers is eliminated.
## Returns the defeated civ_id or &"" if none this check.
func check_conquest(civ_id: StringName, commander_alive: bool, soldier_count: int) -> StringName:
	if not civs.get(civ_id, {}).get("alive", false):
		return &""
	if not commander_alive and soldier_count <= 0:
		civs[civ_id]["alive"] = false
		return civ_id
	return &""

## Prestige: first civ past the threshold wins by prestige.
func check_prestige(civ_id: StringName) -> bool:
	if prestige_score(civ_id) >= prestige_threshold:
		civ_won.emit(civ_id, PRESTIGE)
		return true
	return false

func is_alive(civ_id: StringName) -> bool:
	return civs.get(civ_id, {}).get("alive", false)

func alive_civs() -> Array:
	var out: Array = []
	for c in civs:
		if civs[c]["alive"]:
			out.append(c)
	return out

func winner() -> StringName:
	# Exactly one civ left alive -> conquest winner.
	var alive: Array = alive_civs()
	if alive.size() == 1:
		return alive[0]
	return &""
