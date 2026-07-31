class_name TechTree
extends RefCounted
## Age + tech registry. Shared age spine (Primitive/Metal/Gunpowder-Crystal) with
## per-age techs. Each tech: cost (resources), unlocks (buildings/tools/units),
## and optional peasant-stage bump. Per-civ unique techs hang on the same schema.

enum Age { PRIMITIVE = 1, METAL = 2, GUNPOWDER = 3 }

# Age advancement requirements (resources + a completed building).
const AGE_REQUIREMENTS: Dictionary = {
	Age.METAL: {"cost": {&"food": 500, &"stone": 300}, "building": &"barracks"},
	Age.GUNPOWDER: {"cost": {&"food": 2000, &"stone": 1500, &"gold": 500, &"iron": 100}, "building": &"castle"},
}

# Techs keyed by id. Each: age, cost, unlocks (Array of building/tool/unit ids),
# peasant_stage (optional PeasantStage.Stage to grant on research).
const TECHS: Dictionary = {
	# Age 1 — Primitive
	&"masonry": {"age": Age.PRIMITIVE, "cost": {&"stone": 500, &"clay": 200}, "unlocks": [&"stone_wall"], "peasant_stage": -1},
	&"agriculture": {"age": Age.PRIMITIVE, "cost": {&"food": 300, &"wood": 200}, "unlocks": [&"farm"], "peasant_stage": -1},
	&"woodcrafting": {"age": Age.PRIMITIVE, "cost": {&"wood": 400, &"stone": 100}, "unlocks": [&"wood_siege"], "peasant_stage": -1},
	&"torchlight": {"age": Age.PRIMITIVE, "cost": {&"wood": 200, &"coal": 100}, "unlocks": [&"fire_arrow"], "peasant_stage": -1},
	# Age 2 — Metal
	&"fortification": {"age": Age.METAL, "cost": {&"stone": 800, &"iron": 200}, "unlocks": [&"castle_walls"], "peasant_stage": PeasantStage.Stage.ROAD_BUILDER},
	&"metalworking": {"age": Age.METAL, "cost": {&"iron": 400, &"wood": 300}, "unlocks": [&"iron_tools"], "peasant_stage": PeasantStage.Stage.ROAD_BUILDER},
	&"wheel": {"age": Age.METAL, "cost": {&"wood": 600, &"iron": 100}, "unlocks": [&"cart"], "peasant_stage": PeasantStage.Stage.WHEEL},
	# Age 3 — Gunpowder/Crystal
	&"gunpowder": {"age": Age.GUNPOWDER, "cost": {&"gold": 400, &"coal": 300}, "unlocks": [&"cannon"], "peasant_stage": PeasantStage.Stage.ADVANCED},
	&"crystal_tech": {"age": Age.GUNPOWDER, "cost": {&"crystal": 300, &"gold": 200}, "unlocks": [&"hovercraft"], "peasant_stage": PeasantStage.Stage.ADVANCED},
}

static func tech(tech_id: StringName) -> Dictionary:
	return TECHS.get(tech_id, {})

static func cost(tech_id: StringName) -> Dictionary:
	return TECHS.get(tech_id, {}).get("cost", {})

static func unlocks(tech_id: StringName) -> Array:
	return TECHS.get(tech_id, {}).get("unlocks", [])

static func peasant_stage(tech_id: StringName) -> int:
	return int(TECHS.get(tech_id, {}).get("peasant_stage", -1))

static func techs_for_age(age: int) -> Array:
	var out: Array = []
	for id in TECHS:
		if int(TECHS[id]["age"]) == age:
			out.append(id)
	return out

static func can_advance_to(age: int) -> bool:
	return AGE_REQUIREMENTS.has(age)

static func advance_cost(age: int) -> Dictionary:
	return AGE_REQUIREMENTS.get(age, {}).get("cost", {})

static func advance_building(age: int) -> StringName:
	return AGE_REQUIREMENTS.get(age, {}).get("building", &"")
