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
	&"house": {
		"footprint": Vector2i(3, 3),
		"bom": {&"wood": 25, &"stone": 10},
		"build_time": 8.0,
		"color": Color(0.62, 0.45, 0.30),
	},
	&"storehouse": {
		"footprint": Vector2i(4, 4),
		"bom": {&"wood": 35, &"stone": 15},
		"build_time": 12.0,
		"color": Color(0.50, 0.40, 0.28),
	},
	&"watchtower": {
		"footprint": Vector2i(2, 2),
		"bom": {&"stone": 30, &"wood": 10},
		"build_time": 10.0,
		"color": Color(0.55, 0.55, 0.58),
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
