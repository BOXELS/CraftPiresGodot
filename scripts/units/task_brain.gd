class_name TaskBrain
extends RefCounted
## Task state machine for a Peasant. Holds the current order and walks the unit
## through it each tick: move / gather / haul-to-drop / idle. Standing orders
## (continue same work) and stall-bail per AoE II behavior.

const GATHER_TIME: float = 1.2      # seconds at a node to fill carry
const STALL_LIMIT: float = 3.0      # seconds with no progress before re-path

var unit: Peasant
var order: StringName = &"idle"
var order_data: Dictionary = {}
var state: StringName = &"idle"
var waypoints: Array = []          # queued Vector3 destinations (AoE2 Shift+RMB)

var _state_time: float = 0.0
var _last_pos: Vector3 = Vector3.ZERO
var _stall_time: float = 0.0

func _init(p_unit: Peasant) -> void:
	unit = p_unit

func set_order(new_order: StringName, data: Dictionary) -> void:
	order = new_order
	order_data = data
	_state_time = 0.0
	_stall_time = 0.0
	if new_order != &"move":
		waypoints.clear()
	_enter()

## Queue a move waypoint (Shift+RMB). Starts a move order if not already moving.
func queue_waypoint(pos: Vector3) -> void:
	if order == &"move" and state == &"moving":
		waypoints.append(pos)
		return
	waypoints.clear()
	set_order(&"move", {"pos": pos})

func tick(delta: float) -> void:
	_state_time += delta
	_track_stall(delta)
	match order:
		&"move":
			_tick_move()
		&"gather":
			_tick_gather()
		&"dig":
			_tick_dig()
		&"haul":
			_tick_haul()
		&"build":
			_tick_build()
		&"hunt":
			_tick_hunt()
		&"pickpile":
			_tick_pickpile()
		&"idle":
			state = &"idle"

func _enter() -> void:
	match order:
		&"move":
			state = &"moving"
			unit.move_to(order_data.get("pos", unit.position))
		&"gather":
			state = &"to_node"
			unit.move_to(order_data.get("pos", unit.position))
		&"dig":
			state = &"to_dig"
			unit.move_to(order_data.get("pos", unit.position))
		&"haul":
			state = &"to_depot"
			var depot0: StorageDepot = order_data.get("depot")
			unit.move_to(_depot_point(depot0))
		&"build":
			state = &"to_site"
			unit.move_to(_site_point())
		&"hunt":
			state = &"to_prey"
			unit.move_to(order_data.get("pos", unit.position))
		&"pickpile":
			state = &"to_pile"
			unit.move_to(order_data.get("pos", unit.position))
		_:
			state = &"idle"

func _tick_move() -> void:
	if state == &"moving" and not unit.has_move_target:
		# Arrived — pull next waypoint, or idle.
		if not waypoints.is_empty():
			var next: Vector3 = waypoints.pop_front()
			order_data["pos"] = next
			unit.move_to(next)
			return
		set_order(&"idle", {})

func _tick_gather() -> void:
	match state:
		&"to_node":
			if not unit.has_move_target:
				state = &"gathering"
				_state_time = 0.0
		&"gathering":
			if _state_time >= GATHER_TIME:
				unit.pick_up(order_data.get("kind", &"wood"), unit.CARRY_CAPACITY)
				state = &"to_drop"
				_state_time = 0.0
				unit.move_to(_drop_point())
		&"to_drop":
			if not unit.has_move_target:
				var n: int = unit.drop_off()
				if n > 0:
					Events.add_resource(unit.civ_id, order_data.get("kind", &"wood"), n)
				# Standing order: return to the node and keep gathering.
				state = &"to_node"
				_state_time = 0.0
				unit.move_to(order_data.get("pos", unit.position))

func _drop_point() -> Vector3:
	# Provisional drop point = unit spawn area. Real storage/Keep in Phase 4.
	return order_data.get("drop", unit.get_meta("home", unit.position))

const DIG_TIME: float = 1.5       # base seconds per block; tool/stage speed divides

func _tick_dig() -> void:
	match state:
		&"to_dig":
			if not unit.has_move_target:
				state = &"digging"
				_state_time = 0.0
		&"digging":
			# Work time divided by stage×tool work speed.
			var t: float = DIG_TIME / maxf(unit.work_speed(), 0.1)
			if _state_time >= t:
				var kind: StringName = order_data.get("kind", &"dirt")
				var mat: int = 2 if kind == &"dirt" else 3  # dirt=2, stone=3
				var pos: Vector3 = order_data.get("pos", unit.position)
				if unit.world != null:
					unit.world.dig(int(pos.x), int(pos.z), 1)  # carve the terrain
				unit.pick_up(kind, 1)
				if unit.carrying >= unit.carry_capacity():
					state = &"to_drop_dig"
					_state_time = 0.0
					unit.move_to(_drop_point())
				# else keep digging the same column downward
		&"to_drop_dig":
			if not unit.has_move_target:
				var n: int = unit.drop_off()
				if n > 0:
					Events.add_resource(unit.civ_id, order_data.get("kind", &"dirt"), n)
				state = &"to_dig"
				_state_time = 0.0
				unit.move_to(order_data.get("pos", unit.position))

func _site_point() -> Vector3:
	var site: ConstructionSite = order_data.get("site")
	return site.position if is_instance_valid(site) else unit.position

func _depot_point(depot: StorageDepot) -> Vector3:
	# Depot is logical; haul from near the site/home. Real depot building in Phase 4.
	return order_data.get("depot_pos", unit.get_meta("home", unit.position))

func _tick_haul() -> void:
	var site: ConstructionSite = order_data.get("site")
	var depot: StorageDepot = order_data.get("depot")
	if not is_instance_valid(site) or site.phase == ConstructionSite.Phase.DONE:
		set_order(&"idle", {})
		return
	match state:
		&"to_depot":
			if not unit.has_move_target:
				# Withdraw the needed material up to carry capacity.
				var needed: StringName = site.needed_material()
				if needed == &"":
					# Fully stocked — become a builder on site.
					set_order(&"build", {"site": site})
					return
				var got: int = depot.withdraw(needed, unit.CARRY_CAPACITY)
				if got <= 0:
					# Nothing in storage; wait for stock (idle in place, retry).
					state = &"await_stock"
					_state_time = 0.0
					return
				unit.pick_up(needed, got)
				state = &"to_site_haul"
				unit.move_to(_site_point())
		&"await_stock":
			# Retry withdrawal periodically as gatherers refill storage.
			if _state_time >= 1.0:
				state = &"to_depot"
				_state_time = 0.0
		&"to_site_haul":
			if not unit.has_move_target:
				var delivered_n: int = site.deliver(unit.carry_kind, unit.carrying)
				unit.drop_off()
				if site.is_fully_stocked():
					# All materials on site — switch to building.
					set_order(&"build", {"site": site})
				elif delivered_n > 0 or site.needed_material() != &"":
					# More to haul.
					state = &"to_depot"
					unit.move_to(_depot_point(depot))
				else:
					set_order(&"idle", {})

func _tick_build() -> void:
	var site: ConstructionSite = order_data.get("site")
	if not is_instance_valid(site) or site.phase == ConstructionSite.Phase.DONE:
		site.remove_worker(unit) if is_instance_valid(site) else null
		set_order(&"idle", {})
		return
	match state:
		&"to_site":
			if not unit.has_move_target:
				site.add_worker(unit)
				state = &"building"
				_state_time = 0.0
		&"building":
			# Construction advances via BuildingsManager tick (site.build_tick).
			# Peasant stays at site while stocked; work animation shows.
			if site.phase == ConstructionSite.Phase.DONE:
				site.remove_worker(unit)
				set_order(&"idle", {})

func _track_stall(delta: float) -> void:
	# Bail and re-path if the unit hasn't moved for a while mid-order.
	if state in [&"moving", &"to_node", &"to_drop", &"to_depot", &"to_site", &"to_site_haul", &"to_dig", &"to_drop_dig", &"to_prey", &"to_pile", &"to_drop_pile"] and unit.has_move_target:
		var moved: float = unit.position.distance_to(_last_pos)
		if moved < 0.05:
			_stall_time += delta
			if _stall_time >= STALL_LIMIT:
				_stall_time = 0.0
				unit.move_to(order_data.get("pos", unit.position))  # re-path
		else:
			_stall_time = 0.0
	_last_pos = unit.position

const HUNT_TIME: float = 1.0        # seconds per attack swing

func _tick_hunt() -> void:
	var animals: AnimalField = order_data.get("animals")
	var idx: int = int(order_data.get("index", -1))
	if animals == null or idx < 0:
		set_order(&"idle", {})
		return
	match state:
		&"to_prey":
			if not animals.is_alive(idx):
				# Prey already gone — collect the pile it dropped, if any.
				_go_idle_or_pile()
				return
			# Chase the moving prey.
			unit.move_to(animals.animal_pos(idx))
			if unit.position.distance_to(animals.animal_pos(idx)) < 1.2:
				state = &"attacking"
				_state_time = 0.0
		&"attacking":
			if not animals.is_alive(idx):
				_go_idle_or_pile()
				return
			if _state_time >= HUNT_TIME / maxf(unit.work_speed(), 0.1):
				_state_time = 0.0
				var food: int = animals.damage(idx, 1)
				if food > 0:
					# Killed: haul the food home.
					unit.pick_up(&"food", mini(food, unit.carry_capacity()))
					state = &"to_drop_hunt"
					unit.move_to(_drop_point())
		&"to_drop_hunt":
			if not unit.has_move_target:
				var n: int = unit.drop_off()
				if n > 0:
					Events.add_resource(unit.civ_id, &"food", n)
				set_order(&"idle", {})

func _tick_pickpile() -> void:
	var piles: PileField = order_data.get("piles")
	var idx: int = int(order_data.get("index", -1))
	if piles == null or idx < 0 or piles.pile_amount(idx) <= 0:
		set_order(&"idle", {})
		return
	match state:
		&"to_pile":
			if not unit.has_move_target:
				var got: int = piles.take(idx, unit.carry_capacity())
				if got <= 0:
					set_order(&"idle", {})
					return
				unit.pick_up(piles.pile_kind(idx), got)
				state = &"to_drop_pile"
				unit.move_to(_drop_point())
		&"to_drop_pile":
			if not unit.has_move_target:
				var kind: StringName = order_data.get("kind", &"wood")
				var n: int = unit.drop_off()
				if n > 0:
					Events.add_resource(unit.civ_id, kind, n)
				# Standing order: keep collecting while the pile lasts.
				if piles.pile_amount(idx) > 0:
					state = &"to_pile"
					unit.move_to(piles.pile_pos(idx))
				else:
					set_order(&"idle", {})

func _go_idle_or_pile() -> void:
	set_order(&"idle", {})
