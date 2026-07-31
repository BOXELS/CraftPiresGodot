class_name AgeManager
extends RefCounted
## Tracks a civ's current age, researched techs, and unlocked content. Research
## spends resources through Events; peasant-stage techs bump all that civ's
## peasants. Age advancement is gated by resources + a completed building.

signal tech_researched(tech_id: StringName)
signal age_advanced(new_age: int)

var civ_id: StringName = &"player"
var age: int = TechTree.Age.PRIMITIVE
var researched: Array = []
var unlocked: Dictionary = {}        # id -> true (buildings/tools/units)
var completed_buildings: Array = []  # building kinds finished (for age gates)

func _init(p_civ: StringName = &"player") -> void:
	civ_id = p_civ

func record_building(kind: StringName) -> void:
	if not completed_buildings.has(kind):
		completed_buildings.append(kind)

func is_unlocked(id: StringName) -> bool:
	return unlocked.get(id, false)

func can_research(tech_id: StringName) -> bool:
	var t: Dictionary = TechTree.tech(tech_id)
	if t.is_empty():
		return false
	if researched.has(tech_id):
		return false
	if int(t["age"]) > age:
		return false  # can't research a future age's tech
	return Events.can_afford(civ_id, TechTree.cost(tech_id))

func research(tech_id: StringName, units: UnitManager = null) -> bool:
	if not can_research(tech_id):
		return false
	if not Events.spend(civ_id, TechTree.cost(tech_id)):
		return false
	researched.append(tech_id)
	for u in TechTree.unlocks(tech_id):
		unlocked[u] = true
	# Peasant stage bump applies to all this civ's peasants.
	var stage: int = TechTree.peasant_stage(tech_id)
	if stage >= 0 and units != null:
		for p in units.peasants:
			if is_instance_valid(p) and p.civ_id == civ_id:
				p.set_stage(maxi(p.stage, stage))
	tech_researched.emit(tech_id)
	return true

func can_advance_age() -> bool:
	var next_age: int = age + 1
	if not TechTree.can_advance_to(next_age):
		return false
	if not Events.can_afford(civ_id, TechTree.advance_cost(next_age)):
		return false
	var need_building: StringName = TechTree.advance_building(next_age)
	if need_building != &"" and not completed_buildings.has(need_building):
		return false
	return true

func advance_age(units: UnitManager = null) -> bool:
	if not can_advance_age():
		return false
	var next_age: int = age + 1
	if not Events.spend(civ_id, TechTree.advance_cost(next_age)):
		return false
	age = next_age
	age_advanced.emit(age)
	return true

func available_techs() -> Array:
	# Techs in the current age not yet researched.
	var out: Array = []
	for id in TechTree.techs_for_age(age):
		if not researched.has(id):
			out.append(id)
	return out
