class_name StorageDepot
extends RefCounted
## Per-civ material stockpile. Peasants deposit gathered resources here; hauling
## for construction draws from here. Backed by the Events funnel so accounting
## stays in one place. Phase 4 storehouse buildings raise caps later.

var civ_id: StringName = &"player"
var caps: Dictionary = {&"wood": 200, &"stone": 200, &"dirt": 100, &"thatch": 100}

func _init(p_civ: StringName = &"player") -> void:
	civ_id = p_civ

func deposit(kind: StringName, amount: int) -> int:
	# Accept up to cap; returns accepted amount.
	var cur: int = Events.get_amount(civ_id, kind)
	var room: int = int(caps.get(kind, 100)) - cur
	var accepted: int = mini(amount, maxi(room, 0))
	if accepted > 0:
		Events.add_resource(civ_id, kind, accepted)
	return accepted

func withdraw(kind: StringName, amount: int) -> int:
	# Take out up to what's available for hauling; returns granted amount.
	var cur: int = Events.get_amount(civ_id, kind)
	var granted: int = mini(amount, cur)
	if granted > 0:
		Events.spend(civ_id, {kind: granted})
	return granted

func amount(kind: StringName) -> int:
	return Events.get_amount(civ_id, kind)

func raise_cap(kind: StringName, new_cap: int) -> void:
	caps[kind] = new_cap
