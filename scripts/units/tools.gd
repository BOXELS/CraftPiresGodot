class_name Tools
extends RefCounted
## Hand tools: what they cost to craft and how much they speed up the matching
## job. Crafted at a storehouse (Phase 5 crafting); effect multiplier applies to
## Peasant.work_speed when the tool matches the current task kind.

const COSTS: Dictionary = {
	&"axe": {&"wood": 4, &"stone": 2},
	&"pick": {&"wood": 2, &"stone": 4},
	&"shovel": {&"wood": 3, &"stone": 1},
	&"hammer": {&"wood": 3, &"stone": 3},
}

# Which task kind each tool speeds up, and by how much.
const EFFECTS: Dictionary = {
	&"axe": {"kind": &"wood", "mult": 1.5},     # chop trees faster
	&"pick": {"kind": &"stone", "mult": 1.5},   # mine stone faster
	&"shovel": {"kind": &"dirt", "mult": 1.5},  # dig dirt faster
	&"hammer": {"kind": &"build", "mult": 1.4}, # build faster
}

static func cost(tool: StringName) -> Dictionary:
	return COSTS.get(tool, {})

static func can_craft(civ: StringName, tool: StringName) -> bool:
	return Events.can_afford(civ, cost(tool))

static func craft(civ: StringName, tool: StringName) -> bool:
	# Spend resources; returns true if the tool was made.
	if not COSTS.has(tool):
		return false
	return Events.spend(civ, cost(tool))

static func effect_multiplier(tool: StringName, task_kind: StringName) -> float:
	var e: Dictionary = EFFECTS.get(tool, {})
	if e.is_empty():
		return 1.0
	if task_kind == &"build" and e.get("kind") == &"build":
		return float(e.get("mult", 1.0))
	if e.get("kind") == task_kind:
		return float(e.get("mult", 1.0))
	return 1.0
