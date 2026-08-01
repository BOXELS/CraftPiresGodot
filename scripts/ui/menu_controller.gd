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
var build_bar: BuildBar

# Interaction state.
var pending_kind: StringName = &""          # armed building awaiting a click
var pending_terraform: StringName = &""     # &"dig" / &"raise" awaiting a click
var pending_attack_move: bool = false       # next click is an attack-move target
var pending_pave: bool = false              # dirt-road paint mode (stays armed for drag)
var mouse_mode: StringName = &"rts"         # &"rts" or &"fmode"
var graphics_quality: StringName = &"high"

# Build-bar depth: 0=top categories, 1=group, 2=folder (AoE2 / Three.js MVP).
var _bar_depth: int = 0
var _bar_category: StringName = &""
var _bar_folder: Array = []
var _bar_folder_id: StringName = &""
const BAR_CATEGORIES: Array = [&"settlement", &"defense", &"crafting"]

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
	build_bar = BuildBar.new()
	add_child(build_bar)
	build_bar.group_pressed.connect(_on_bar_group)
	build_bar.folder_pressed.connect(_on_bar_folder)
	build_bar.item_pressed.connect(_on_bar_item)
	build_bar.back_pressed.connect(pop_bar)
	# Hidden until Single Player starts (world sims behind the title menu).
	build_bar.visible = false

func set_build_bar_visible(on: bool) -> void:
	if build_bar != null:
		build_bar.visible = on
		if on:
			_sync_bar()

func is_busy() -> bool:
	return radial.is_open() or _bar_depth > 0

# --- Radial open/track/confirm -------------------------------------------

func open_radial(at: Vector2 = Vector2.INF) -> void:
	radial.open(ShortcutMenus.radial_root(), at)

func track_radial(mouse_pos: Vector2) -> void:
	if radial.is_open():
		radial.track(mouse_pos)

func release_radial() -> void:
	if radial.is_open():
		radial.confirm_hover()

func pop_radial() -> void:
	if radial.is_open():
		radial.pop_level()

# --- Build bar (AoE2 swap-in-place, matching Three.js MVP) ----------------

func toggle_bar_category(index: int) -> void:
	# Top-level digits open a group; same digit again (while at that group top) closes.
	var cat: StringName = BAR_CATEGORIES[index]
	if _bar_depth == 1 and _bar_category == cat:
		_close_bar()
		return
	if _bar_depth == 2 and _bar_category == cat:
		# Same category digit while in a folder → back to the group row.
		_bar_depth = 1
		_bar_folder = []
		_bar_folder_id = &""
		_sync_bar()
		return
	_bar_depth = 1
	_bar_category = cat
	_bar_folder = []
	_bar_folder_id = &""
	_sync_bar()

func bar_select_item(index: int) -> void:
	# Digits pick an entry at the current depth (group or folder).
	if _bar_depth < 1:
		return
	var items: Array = _current_bar_items()
	if index < 0 or index >= items.size():
		return
	_activate_entry(items[index])

func _current_bar_items() -> Array:
	if _bar_depth == 2:
		return _bar_folder
	var row: Dictionary = ShortcutMenus.build_bar_rows().get(_bar_category, {})
	return row.get("items", [])

func pop_bar() -> void:
	if _bar_depth == 2:
		_bar_depth = 1
		_bar_folder = []
		_bar_folder_id = &""
		_sync_bar()
	elif _bar_depth == 1:
		_close_bar()

func _close_bar() -> void:
	_bar_depth = 0
	_bar_category = &""
	_bar_folder = []
	_bar_folder_id = &""
	_sync_bar()

func _sync_bar() -> void:
	if build_bar == null:
		return
	build_bar.set_active_kind(pending_kind)
	build_bar.set_pave_active(pending_pave)
	if _bar_depth == 0:
		build_bar.close_to_top()
	elif _bar_depth == 2:
		build_bar.open_group(_bar_category)
		build_bar.open_folder(_bar_folder_id, _bar_folder)
	else:
		build_bar.open_group(_bar_category)

func _on_bar_group(group_id: StringName) -> void:
	var idx: int = BAR_CATEGORIES.find(group_id)
	if idx >= 0:
		toggle_bar_category(idx)

func _on_bar_folder(folder_id: StringName, children: Array) -> void:
	_bar_folder_id = folder_id
	_bar_folder = children
	_bar_depth = 2
	_sync_bar()

func _on_bar_item(entry: Dictionary) -> void:
	_activate_entry(entry)

func _activate_entry(entry: Dictionary) -> void:
	if entry.has("children"):
		_bar_folder_id = entry.get("id", &"folder")
		_bar_folder = entry["children"]
		_bar_depth = 2
		_sync_bar()
		return
	# Leaf: arm place/pave but keep the bar open on the current row so the
	# active button highlights (AoE2 stays in the menu while placing).
	if entry.get("pave", false):
		arm_pave()
	else:
		arm_placement(entry.get("id", &""))
	_sync_bar()

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
		&"toggle_fullscreen":
			var on: bool = Controls.toggle_fullscreen()
			action_feedback.emit("Fullscreen: %s" % ("on" if on else "off"))
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
	pending_pave = false
	placement_armed.emit(kind)
	action_feedback.emit("Placing %s — click terrain (Esc to cancel)" % str(kind).capitalize())
	if build_bar != null:
		build_bar.set_active_kind(pending_kind)
		build_bar.set_pave_active(false)

func arm_pave() -> void:
	# Improvement vs Three.js: stay in paint mode for drag strokes until Esc —
	# no re-open of the menu between strokes.
	pending_pave = true
	pending_kind = &""
	pending_terraform = &""
	pending_attack_move = false
	action_feedback.emit("Dirt road — drag to paint (%d dirt/tile, +35%% speed). Esc cancels" % MaterialInteractions.DIRT_ROAD_COST)
	if build_bar != null:
		build_bar.set_active_kind(&"")
		build_bar.set_pave_active(true)

## Paint one dirt-road tile. Returns true if the surface changed.
func paint_road_at(pos: Vector3) -> bool:
	if world == null:
		return false
	var x: int = int(pos.x)
	var z: int = int(pos.z)
	var mat: int = world.shard.surface_material(x, z)
	if mat == MaterialInteractions.ROAD_DIRT:
		return false
	if not MaterialInteractions.can_pave_dirt_road(mat):
		action_feedback.emit("Roads go on grass or dirt")
		return false
	if not Events.spend(&"player", {&"dirt": MaterialInteractions.DIRT_ROAD_COST}):
		action_feedback.emit("Need %d dirt (dig ground, or Esc to cancel)" % MaterialInteractions.DIRT_ROAD_COST)
		return false
	if not world.pave_dirt_road(x, z):
		# Refund if pave somehow failed after spend.
		Events.add_resource(&"player", &"dirt", MaterialInteractions.DIRT_ROAD_COST)
		return false
	return true

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
	if pending_pave:
		# Stay armed so the player can drag / click more tiles.
		paint_road_at(pos)
		return true
	if pending_kind != &"":
		_place_pending(pos)
		# Improvement: stay in place mode for rapid multi-place (like MVP Shift
		# stroke, but without requiring Shift — Esc cancels).
		return true
	return false

func cancel_pending() -> void:
	pending_kind = &""
	pending_terraform = &""
	pending_attack_move = false
	pending_pave = false
	if build_bar != null:
		build_bar.set_active_kind(&"")
		build_bar.set_pave_active(false)

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
