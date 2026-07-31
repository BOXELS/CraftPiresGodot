extends Node
## Events autoload: central signal bus and the only funnel for resource mutation.
## All gameplay resource changes go through add_resource / spend so multiplayer
## and save/load later have a single authoritative path.

signal resource_added(civ_id: StringName, kind: StringName, amount: int)
signal resource_spent(civ_id: StringName, kind: StringName, amount: int)
@warning_ignore("unused_signal")
signal order_issued(unit_id: int, order: StringName, payload: Dictionary)

# Per-civ resource ledger. Network-ready shape even in single-player.
var _resources: Dictionary = {}

func add_resource(civ_id: StringName, kind: StringName, amount: int) -> void:
	if amount <= 0:
		return
	var civ: Dictionary = _resources.get(civ_id, {})
	civ[kind] = int(civ.get(kind, 0)) + amount
	_resources[civ_id] = civ
	resource_added.emit(civ_id, kind, amount)

func can_afford(civ_id: StringName, costs: Dictionary) -> bool:
	var civ: Dictionary = _resources.get(civ_id, {})
	for kind in costs:
		if int(civ.get(kind, 0)) < int(costs[kind]):
			return false
	return true

func spend(civ_id: StringName, costs: Dictionary) -> bool:
	if not can_afford(civ_id, costs):
		return false
	var civ: Dictionary = _resources.get(civ_id, {})
	for kind in costs:
		civ[kind] = int(civ.get(kind, 0)) - int(costs[kind])
		resource_spent.emit(civ_id, kind, int(costs[kind]))
	_resources[civ_id] = civ
	return true

func get_amount(civ_id: StringName, kind: StringName) -> int:
	return int(_resources.get(civ_id, {}).get(kind, 0))

func get_civ_resources(civ_id: StringName) -> Dictionary:
	return _resources.get(civ_id, {}).duplicate(true)

func reset() -> void:
	_resources.clear()
