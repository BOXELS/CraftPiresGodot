class_name PeasantStage
extends RefCounted
## Peasant progression tiers. Stage rises with age progression (Phase 8 formalizes
## ages); for now stages are granted manually / via milestones. Higher stage =
## more carry, faster move, faster work, and a better outfit.

enum Stage { PRIMITIVE = 0, ROAD_BUILDER = 1, WHEEL = 2, ADVANCED = 3 }

const DATA: Dictionary = {
	Stage.PRIMITIVE: {"carry": 10, "speed": 2.6, "work": 1.0, "outfit": "wood"},
	Stage.ROAD_BUILDER: {"carry": 20, "speed": 2.9, "work": 1.4, "outfit": "stone"},
	Stage.WHEEL: {"carry": 50, "speed": 3.3, "work": 1.8, "outfit": "iron"},
	Stage.ADVANCED: {"carry": 100, "speed": 3.8, "work": 2.4, "outfit": "gold"},
}

static func carry(stage: int) -> int:
	return int(DATA.get(stage, DATA[Stage.PRIMITIVE])["carry"])

static func speed(stage: int) -> float:
	return float(DATA.get(stage, DATA[Stage.PRIMITIVE])["speed"])

static func work(stage: int) -> float:
	return float(DATA.get(stage, DATA[Stage.PRIMITIVE])["work"])

static func outfit(stage: int) -> String:
	return str(DATA.get(stage, DATA[Stage.PRIMITIVE])["outfit"])

static func stage_name(stage: int) -> String:
	match stage:
		Stage.PRIMITIVE: return "Primitive"
		Stage.ROAD_BUILDER: return "Road-Builder"
		Stage.WHEEL: return "Wheel-Discovering"
		Stage.ADVANCED: return "Advanced"
	return "Unknown"
