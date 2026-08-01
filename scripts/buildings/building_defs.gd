class_name BuildingDefs
extends RefCounted
## Building type registry: bill of materials, footprint, and build phases.
## All data — no assets. Visuals are voxel scaffolds built up per phase.

# Material kinds: &"wood", &"stone", &"dirt", &"thatch"
const TYPES: Dictionary = {
	&"keep": {
		"footprint": Vector2i(6, 6),
		"bom": {&"stone": 60, &"wood": 40},
		"build_time": 20.0,
		"color": Color(0.60, 0.58, 0.62),
	},
	# Houses (pop bonus scales with tier).
	&"house": {
		"footprint": Vector2i(3, 3),
		"bom": {&"wood": 25, &"stone": 10},
		"build_time": 8.0,
		"color": Color(0.62, 0.45, 0.30),
		"pop_bonus": 5, "min_age": 0,
	},
	&"house_medium": {
		"footprint": Vector2i(4, 4),
		"bom": {&"wood": 45, &"stone": 15},
		"build_time": 12.0,
		"color": Color(0.64, 0.48, 0.32),
		"pop_bonus": 8, "min_age": 1,
	},
	&"house_large": {
		"footprint": Vector2i(5, 5),
		"bom": {&"wood": 70, &"stone": 25},
		"build_time": 16.0,
		"color": Color(0.66, 0.50, 0.34),
		"pop_bonus": 12, "min_age": 2,
	},
	# Storage tiers.
	&"storehouse": {
		"footprint": Vector2i(4, 4),
		"bom": {&"wood": 35, &"stone": 15},
		"build_time": 12.0,
		"color": Color(0.50, 0.40, 0.28),
	},
	&"storehouse_medium": {
		"footprint": Vector2i(5, 5),
		"bom": {&"wood": 60, &"stone": 35},
		"build_time": 16.0,
		"color": Color(0.52, 0.42, 0.30),
	},
	&"storageyard": {
		"footprint": Vector2i(3, 3),
		"bom": {&"wood": 10, &"stone": 5},
		"build_time": 6.0,
		"color": Color(0.55, 0.46, 0.34),
	},
	# Defense.
	&"watchtower": {
		"footprint": Vector2i(2, 2),
		"bom": {&"stone": 30, &"wood": 10},
		"build_time": 10.0,
		"color": Color(0.55, 0.55, 0.58),
	},
	# Crafting / tech.
	&"researchhall": {
		"footprint": Vector2i(3, 3),
		"bom": {&"wood": 25, &"stone": 10},
		"build_time": 8.0,
		"color": Color(0.45, 0.50, 0.62),
	},
	&"toolsmith": {
		"footprint": Vector2i(3, 3),
		"bom": {&"wood": 35, &"stone": 15},
		"build_time": 10.0,
		"color": Color(0.50, 0.42, 0.40),
	},
	&"weaponsmith": {
		"footprint": Vector2i(3, 3),
		"bom": {&"wood": 35, &"stone": 20},
		"build_time": 10.0,
		"color": Color(0.48, 0.40, 0.42),
	},
}

static func get_def(kind: StringName) -> Dictionary:
	return TYPES.get(kind, {})

static func bom(kind: StringName) -> Dictionary:
	return TYPES.get(kind, {}).get("bom", {})

static func footprint(kind: StringName) -> Vector2i:
	return TYPES.get(kind, {}).get("footprint", Vector2i(2, 2))

static func build_time(kind: StringName) -> float:
	return float(TYPES.get(kind, {}).get("build_time", 10.0))

static func color(kind: StringName) -> Color:
	return TYPES.get(kind, {}).get("color", Color.GRAY)

static func pop_bonus(kind: StringName) -> int:
	return int(TYPES.get(kind, {}).get("pop_bonus", 0))

static func is_house(kind: StringName) -> bool:
	return pop_bonus(kind) > 0

static func min_age(kind: StringName) -> int:
	return int(TYPES.get(kind, {}).get("min_age", 0))
