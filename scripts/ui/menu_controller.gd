class_name MenuController
extends CanvasLayer
## Owns the radial shortcut menu + the nested build bar, and turns menu choices
## into real game actions (place building, attack-move, terraform, train, mode
## toggles, save). Held by main.gd; scenario tests drive it headlessly.

signal placement_armed(kind: StringName)   # a building kind is armed for next click
signal action_feedback(text: String)       # one-line status for the HUD

var world: WorldBuilder
var units: UnitManager
var buildings: BuildingsManager
var combat: CombatManager
var depot: StorageDepot
var commander: Commander

var radial: RadialMenu
var _build_label: Label

# Interaction state.
var pending_kind: StringName = &""          # armed building awaiting a click
var pending_terraform: StringName = &""     # &"dig" / &"raise" awaiting a click
var pending_attack_move: bool = false       # next click is an attack-move target
var mouse_mode: StringName = &"rts"         # &"rts" or &"fmode"
var graphics_quality: StringName = &"high"

# Build-bar depth state: 0=closed, 1=category, 2=item list.
var _bar_depth: int = 0
var _bar_category: StringName = &""
const BAR_CATEGORIES: Array = [&"economy", &"military", &"wonder"]

func setup(p_world: WorldBuilder, p_units: UnitManager, p_buildings: BuildingsManager, p_combat: CombatManager, p_depot: StorageDepot, p_commander: Commander) -> void:
	world = p_world
	units = p_units
	buildings = p_buildings
	combat = p_combat
	depot = p_depot
	commander = p_commander

func _ready() -> void:
	layer = 10
	radial = RadialMenu.new()
	add_child(radial)
	radial.action_chosen.connect(_on_radial_action)
	_build_label = Label.new()
	_build_label.position = Vector2(16, 44)
	_build_label.add_theme_color_override("font_color", Color(1, 1, 1, 0.92))
	add_child(_build_label)
	_refresh_build_label()

func is_busy() -> bool:
	return radial.is_open() or _bar_depth > 0

# --- Radial open/track/confirm -------------------------------------------

func open_radial() -> void:
	radial.open(ShortcutMenus.radial_root())

func track_radial(mouse_pos: Vector2) -> void:
	if radial.is_open():
		radial.track(mouse_pos)

func release_radial() -> void:
	if radial.is_open():
		radial.confirm_hover()

func pop_radial() -> void:
	if radial.is_open():
		radial.pop_level()

# --- Build bar (AoE2 drill-down) ------------------------------------------

func toggle_bar_category(index: int) -> void:
	# 1=Econ, 2=Military, 3=Wonder. Same key again pops back a level.
	var cat: StringName = BAR_CATEGORIES[index]
	if _bar_depth == 1 and _bar_category == cat:
		_bar_depth = 0
		_bar_category = &""
	elif _bar_depth == 2 and _bar_category == cat:
		_bar_depth = 1
	else:
		_bar_depth = 1
		_bar_category = cat
	_refresh_build_label()

func bar_select_item(index: int) -> void:
	# While a category is open, number keys pick a building from its row.
	if _bar_depth < 1:
		return
	var row: Dictionary = ShortcutMenus.build_bar_rows().get(_bar_category, {})
	var items: Array = row.get("items", [])
	if index < 0 or index >= items.size():
		return
	arm_placement(items[index])
	_bar_depth = 0
	_bar_category = &""
	_refresh_build_label()

func pop_bar() -> void:
	if _bar_depth == 2:
		_bar_depth = 1
	elif _bar_depth == 1:
		_bar_depth = 0
		_bar_category = &""
	_refresh_build_label()

func _refresh_build_label() -> void:
	if _build_label == null:
		return
	if _bar_depth == 0:
		_build_label.text = ""
		return
	if _bar_depth == 1:
		var row: Dictionary = ShortcutMenus.build_bar_rows().get(_bar_category, {})
		var parts: Array = []
		var items: Array = row.get("items", [])
		for i in items.size():
			parts.append("%d %s" % [i + 1, str(items[i]).capitalize()])
		_build_label.text = "[%s]  %s   (Esc to close)" % [str(row.get("label", "")), "   ".join(parts)]

# --- Radial action handling ------------------------------------------------

func _on_radial_action(id: StringName, payload: Variant) -> void:
	match id:
		&"place":
			arm_placement(payload)
		&"attack_move":
			pending_attack_move = true
			pending_kind = &""
			pending_terraform = &""
			action_feedback.emit("Attack-move: click a target point")
		&"terraform_dig":
			pending_terraform = &"dig"
			action_feedback.emit("Terraform dig: click terrain to carve")
		&"terraform_raise":
			pending_terraform = &"raise"
			action_feedback.emit("Terraform raise: click terrain to build up")
		&"train_soldier":
			_train_soldier()
		&"select_army":
			action_feedback.emit("Army selected: %d soldier(s) — use Attack Move" % _army().size())
		&"stop_units":
			_stop_units()
		&"toggle_mouse_mode":
			toggle_mouse_mode()
		&"gfx_high":
			set_graphics_quality(&"high")
		&"gfx_medium":
			set_graphics_quality(&"medium")
		&"gfx_low":
			set_graphics_quality(&"low")
		&"save_game":
			action_feedback.emit("save_requested")

func arm_placement(kind: StringName) -> void:
	pending_kind = kind
	pending_terraform = &""
	pending_attack_move = false
	placement_armed.emit(kind)
	action_feedback.emit("Placing %s — click terrain (Esc to cancel)" % str(kind).capitalize())

## Handle a left-click on terrain while a menu action is armed. Returns true if
## the click was consumed by the menu layer (so normal click-to-move is skipped).
func handle_terrain_click(pos: Vector3) -> bool:
	if pending_attack_move:
		_attack_move_to(pos)
		pending_attack_move = false
		return true
	if pending_terraform != &"":
		_apply_terraform(pos)
		pending_terraform = &""
		return true
	if pending_kind != &"":
		_place_pending(pos)
		pending_kind = &""
		return true
	return false

func cancel_pending() -> void:
	pending_kind = &""
	pending_terraform = &""
	pending_attack_move = false

# --- Concrete actions -------------------------------------------------------

func _place_pending(pos: Vector3) -> void:
	if buildings == null:
		return
	if not Events.spend(&"player", BuildingDefs.bom(pending_kind)):
		action_feedback.emit("Not enough materials for %s" % str(pending_kind).capitalize())
		return
	var tile := Vector3i(int(pos.x), 0, int(pos.z))
	var site: ConstructionSite = buildings.place(pending_kind, tile, &"player")
	_send_builders(site)
	action_feedback.emit("%s foundation placed" % str(pending_kind).capitalize())

func _send_builders(site: ConstructionSite) -> void:
	var peasants: Array = units.peasants.duplicate()
	peasants.sort_custom(func(a: Peasant, b: Peasant) -> bool:
		return a.position.distance_squared_to(site.position) < b.position.distance_squared_to(site.position))
	var sent: int = 0
	for p in peasants:
		if sent >= 3:
			break
		if p.carrying > 0:
			continue
		p.order_haul(site, depot)
		sent += 1

func _attack_move_to(pos: Vector3) -> void:
	var army: Array = _army()
	for s in army:
		s.order_attack_move(pos)
	action_feedback.emit("Attack-move: %d soldier(s) advancing" % army.size())

func _army() -> Array:
	if combat == null:
		return []
	return combat.soldiers_for(&"player")

func _train_soldier() -> void:
	if combat == null or commander == null:
		return
	if not Events.spend(&"player", {&"wood": 10, &"stone": 5}):
		action_feedback.emit("Not enough resources to train (10 wood, 5 stone)")
		return
	var fwd: Vector3 = -commander.global_transform.basis.z
	fwd.y = 0.0
	if fwd.length() < 0.1:
		fwd = Vector3(1, 0, 0)
	var spot: Vector3 = commander.position + fwd.normalized() * 3.0
	var gy: int = world.shard.get_height(int(spot.x), int(spot.z))
	combat.spawn_soldier(Vector3(spot.x, gy, spot.z), 0, &"player", "stone")
	action_feedback.emit("Soldier trained")

func _stop_units() -> void:
	var stopped: int = 0
	for s in _army():
		if is_instance_valid(s):
			s.guard_post = s.position
			s.target = null
			stopped += 1
	for p in units.peasants:
		if is_instance_valid(p) and p.has_move_target:
			p.has_move_target = false
			stopped += 1
	action_feedback.emit("Stopped %d unit(s)" % stopped)

func _apply_terraform(pos: Vector3) -> void:
	if world == null:
		return
	if pending_terraform == &"dig":
		world.dig(int(pos.x), int(pos.z), 1)
		action_feedback.emit("Dug at (%d, %d)" % [int(pos.x), int(pos.z)])
	elif pending_terraform == &"raise":
		world.raise(int(pos.x), int(pos.z), 1, 2)
		action_feedback.emit("Raised at (%d, %d)" % [int(pos.x), int(pos.z)])

func toggle_mouse_mode() -> StringName:
	mouse_mode = &"fmode" if mouse_mode == &"rts" else &"rts"
	action_feedback.emit("Mouse mode: %s" % ("F-mode WASD free-look" if mouse_mode == &"fmode" else "RTS click-to-move"))
	return mouse_mode

func set_graphics_quality(q: StringName) -> void:
	graphics_quality = q
	_apply_graphics()
	action_feedback.emit("Graphics: %s" % str(q).capitalize())

func _apply_graphics() -> void:
	# Scale the 3D render resolution: a real, immediate perf lever with no art.
	var vp := get_viewport()
	if vp == null:
		return
	match graphics_quality:
		&"high":
			vp.scaling_3d_scale = 1.0
		&"medium":
			vp.scaling_3d_scale = 0.75
		&"low":
			vp.scaling_3d_scale = 0.5
