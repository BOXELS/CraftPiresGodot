extends Node
## Entry point. Normal runs show the title/game shell; --scenario=<name> runs a
## regression scenario from tests/scenarios/ and exits with pass/fail.

const SCENARIO_DIR: String = "res://tests/scenarios/"

var _camera: CameraRig
var _commander: Commander
var _units: UnitManager
var _buildings: BuildingsManager
var _depot: StorageDepot
var _world: WorldBuilder
var _fog: FogOfWar
var _territory: Territory
var _combat: CombatManager
var _age: AgeManager
var _ai: AIOpponent
var _wincon: WinConditions
var _season: Season
var _menu: MenuController
var _hud_label: Label
var _place_cooldown: float = 0.0

func _ready() -> void:
	var scenario: String = _get_scenario_arg()
	if not scenario.is_empty():
		_run_scenario(scenario)
	else:
		_show_title()

func _get_scenario_arg() -> String:
	return _get_flag_arg("--scenario=")

func _get_flag_arg(prefix: String) -> String:
	var args: PackedStringArray = OS.get_cmdline_user_args()
	for arg in args:
		if arg.begins_with(prefix):
			return arg.trim_prefix(prefix)
	return ""

func _frame_overview(_world: Node) -> void:
	# High, far view over the map center so terrain regions read in one frame.
	var cx: float = VoxelShard.SIZE_X / 2.0
	var cz: float = VoxelShard.SIZE_Z / 2.0
	_camera.position = Vector3(cx, 0.0, cz)
	_camera._zoom = 90.0
	_camera._apply_boom()

func _frame_at(pos: Vector3, zoom: float) -> void:
	_camera.position = Vector3(pos.x, 0.0, pos.z)
	_camera._zoom = clampf(zoom, _camera.zoom_min, _camera.zoom_max)
	_camera._apply_boom()

func _run_scenario(scenario_name: String) -> void:
	var path: String = "%s%s.gd" % [SCENARIO_DIR, scenario_name]
	if not ResourceLoader.exists(path):
		push_error("Unknown scenario: %s (expected %s)" % [scenario_name, path])
		get_tree().quit(1)
		return
	var script: GDScript = load(path)
	var node: Node = Node.new()
	node.set_script(script)
	add_child(node)

func _show_title() -> void:
	# Phase 1+2+3: straight into the world; title menu returns in Phase 11.
	var world := WorldBuilder.new()
	world.name = "World"
	add_child(world)
	_world = world
	var world_seed: int = int(_get_flag_arg("--seed=")) if not _get_flag_arg("--seed=").is_empty() else 12345
	world.build(world_seed)

	# Scatter trees on the grass.
	var resources := ResourceNodes.new()
	resources.name = "Resources"
	add_child(resources)
	resources.setup(world.shard)
	var rng := RandomNumberGenerator.new()
	rng.seed = 777
	resources.scatter(rng, 120)

	_camera = CameraRig.new()
	_camera.name = "CameraRig"
	add_child(_camera)

	# Spawn commander on the surface near center.
	_commander = Commander.new()
	_commander.name = "Commander"
	add_child(_commander)
	_commander.setup(world.shard, 0)
	var cx: int = int(VoxelShard.SIZE_X / 2.0)
	var cz: int = int(VoxelShard.SIZE_Z / 2.0)
	var gy: int = world.shard.get_height(cx, cz)
	_commander.position = Vector3(cx + 0.5, gy, cz + 0.5)
	_commander.cargo_changed.connect(_on_cargo_changed)

	# Spawn a few peasants near the commander; sim drives their brains.
	_units = UnitManager.new()
	_units.name = "Units"
	add_child(_units)
	_units.setup(world.shard, world)
	for i in 4:
		var px: float = cx + 2.0 + float(i % 2) * 1.5
		var pz: float = cz + 2.0 + float(i / 2) * 1.5
		var ph: int = world.shard.get_height(int(px), int(pz))
		_units.spawn_peasant(Vector3(px, ph, pz), 0)
		Sim.start_sim(12345)

	# Starting storage so early construction is possible.
	Events.add_resource(&"player", &"wood", 80)
	Events.add_resource(&"player", &"stone", 40)
	_depot = StorageDepot.new(&"player")

	# Press B to place a house foundation near the commander; nearby peasants
	# auto-haul from storage and build it.
	_buildings = BuildingsManager.new()
	_buildings.name = "Buildings"
	add_child(_buildings)
	_buildings.setup(world.shard)

	# Phase 6: fog of war + territory claim for the player civ.
	_fog = FogOfWar.new(&"player")
	_territory = Territory.new(&"player")
	_buildings.site_completed_claim.connect(_on_building_claim)

	# Phase 7: combat. A couple of player soldiers guard near spawn; a small
	# enemy force lurks to the north so first contact happens if you wander.
	_combat = CombatManager.new()
	_combat.name = "Combat"
	add_child(_combat)
	_combat.setup(world.shard)
	for i in 2:
		_combat.spawn_soldier(Vector3(cx - 2.0, gy, cz + 1.0 + float(i)), 0, &"player", "stone")
	_commander.add_to_group("combatants")

	# Phase 8: age progression. Buildings that complete feed the age gates.
	_age = AgeManager.new(&"player")
	_age.age_advanced.connect(_on_age_advanced)

	# Phase 10: enemy AI civ to the north-east + win conditions. The static
	# enemy squad above is replaced by a living opponent that builds an economy.
	Events.add_resource(&"enemy", &"wood", 150)
	Events.add_resource(&"enemy", &"stone", 80)
	var ai_home := Vector3(cx + 26, 0, cz + 26)
	ai_home.y = world.shard.get_height(int(ai_home.x), int(ai_home.z))
	_ai = AIOpponent.new(world, _units, _combat, _buildings, StorageDepot.new(&"enemy"), ai_home, 555)
	_ai.setup_economy(3, 2)
	_wincon = WinConditions.new()
	_wincon.register(&"player")
	_wincon.register(&"enemy")
	_wincon.civ_won.connect(_on_civ_won)

	# Phase 11: season lifecycle + hall of legends.
	_season = Season.new()
	_season.season_ended.connect(_on_season_ended)

	# Shortcut menus: hold-Tab radial + nested build bar, wired to the world.
	_menu = MenuController.new()
	_menu.name = "Menus"
	add_child(_menu)
	_menu.setup(world, _units, _buildings, _combat, _depot, _commander)
	_menu.action_feedback.connect(_on_menu_feedback)

	# Optional: --menu-demo opens the radial menu (drilled into a submenu) and
	# hovers a wedge so a --screenshot captures the shortcut-menu UI.
	var demo_arg: String = _get_flag_arg("--menu-demo=")
	if not demo_arg.is_empty() or OS.get_cmdline_user_args().has("--menu-demo"):
		var which: String = demo_arg if not demo_arg.is_empty() else "build"
		_menu.open_radial()
		var cat: int = {"build": 0, "actions": 1, "settings": 2}.get(which, 0)
		_menu.radial._hover = cat
		_menu.radial.confirm_hover()   # drill into the category's submenu
		_menu.radial._hover = 0        # hover the first item for the shot
		_menu.radial.queue_redraw()
		_frame_overview(world)
		var demo_shot: String = _get_flag_arg("--screenshot=")
		if not demo_shot.is_empty():
			# Headless has no frame_post_draw; let two frames process so the
			# CanvasLayer draws, then capture the viewport.
			await get_tree().process_frame
			await get_tree().process_frame
			get_viewport().get_texture().get_image().save_png(demo_shot)
		get_tree().quit(0)
		return

	_camera.focus_on(_commander.position)

	# Optional: --screenshot=<path> frames the whole map and saves a PNG, then
	# quits. Used for quick visual checks of terrain/layout from the CLI.
	# Optional: --terraform-demo carves a trench + crater to prove live editing,
	# for the screenshot visual check.
	if not _get_flag_arg("--terraform-demo").is_empty() or OS.get_cmdline_user_args().has("--terraform-demo"):
		for i in range(30, 70):
			world.dig(i, 80, 4)         # trench across the plains
		for dx in range(-6, 7):
			for dz in range(-6, 7):
				if dx * dx + dz * dz <= 36:
					world.dig(96 + dx, 96 + dz, 3)  # crater
		# A raised mound.
		for dx in range(-4, 5):
			for dz in range(-4, 5):
				if dx * dx + dz * dz <= 16:
					world.raise(40, 40, 2, 2)

	# Optional: --quarry-demo sends peasants to dig a pit over a few seconds,
	# then screenshots the carved terrain for the Phase 5 visual check.
	if OS.get_cmdline_user_args().has("--quarry-demo"):
		for i in range(mini(3, _units.peasants.size())):
			var p: Peasant = _units.peasants[i]
			p.order_dig(Vector3(58.5 + float(i), 0, 74.5), &"dirt")
		# Let the sim dig for a bit before the shot.
		for f in 600:
			await get_tree().physics_frame

	# Optional: --combat-demo throws player and enemy squads together for a
	# melee screenshot for the Phase 7 visual check.
	if OS.get_cmdline_user_args().has("--combat-demo"):
		for f in 240:
			await get_tree().physics_frame
		_frame_at(Vector3(cx - 10, 0, cz - 10), 30.0)

	# Optional: --water-demo pours a pool on the plains, steps the sim, renders
	# it, and screenshots the translucent water for the Phase 11 visual check.
	if OS.get_cmdline_user_args().has("--water-demo"):
		for i in range(56, 66):
			for j in range(56, 66):
				_world.water.set_water(i, j, 5)
		for s in 12:
			_world.water.step(0, 0, VoxelShard.SIZE_X, VoxelShard.SIZE_Z)
		_world.render_water()
		_frame_at(Vector3(60, 0, 60), 32.0)

	var shot_path: String = _get_flag_arg("--screenshot=")
	if not shot_path.is_empty():
		if OS.get_cmdline_user_args().has("--quarry-demo"):
			_frame_at(Vector3(58, 0, 74), 34.0)
		elif OS.get_cmdline_user_args().has("--combat-demo") or OS.get_cmdline_user_args().has("--water-demo"):
			pass  # framed above
		else:
			_frame_overview(world)
		await RenderingServer.frame_post_draw
		get_viewport().get_texture().get_image().save_png(shot_path)
		get_tree().quit(0)
		return

	_hud_label = Label.new()
	_hud_label.text = ""
	_hud_label.position = Vector2(16, 12)
	_hud_label.add_theme_color_override("font_color", Color(1, 1, 1, 0.9))
	var layer := CanvasLayer.new()
	layer.add_child(_hud_label)
	add_child(layer)
	_update_hud()

func _unhandled_input(event: InputEvent) -> void:
	if _commander == null or _camera == null:
		return
	if event is InputEventMouseButton:
		var mb := event as InputEventMouseButton
		if mb.button_index == MOUSE_BUTTON_LEFT and mb.pressed:
			var pos: Variant = _terrain_click(mb.position)
			if pos != null:
				# Menu layer gets first crack at the click (armed placement /
				# attack-move / terraform). Fall through to normal movement.
				if _menu != null and _menu.handle_terrain_click(pos):
					return
				if Input.is_key_pressed(KEY_SHIFT):
					_commander.order_beam_gather(pos)
				else:
					_commander.order_move(pos)
		elif mb.button_index == MOUSE_BUTTON_RIGHT and mb.pressed:
			var pos: Variant = _terrain_click(mb.position)
			if pos != null:
				if Input.is_key_pressed(KEY_SHIFT):
					_raise_at(pos)
				elif Input.is_key_pressed(KEY_CTRL) or Input.is_key_pressed(KEY_META):
					_dig_at(pos)        # instant carve (debug)
				else:
					_order_dig(pos)     # send a peasant to dig/mine here
	elif event is InputEventMouseMotion:
		# Track the radial wedge while the open key is held.
		if _menu != null and Input.is_action_pressed("radial_menu"):
			_menu.track_radial((event as InputEventMouseMotion).position)
	elif event is InputEventKey:
		var k := event as InputEventKey
		if k.pressed and not k.echo and k.keycode == KEY_B:
			_place_house()
		elif k.pressed and not k.echo and k.keycode == KEY_S:
			_spawn_soldier()
		elif k.pressed and not k.echo and k.keycode == KEY_T:
			_research_next()
		elif k.pressed and not k.echo and k.keycode == KEY_ESCAPE:
			_on_escape()
		elif k.pressed and not k.echo and k.keycode >= KEY_1 and k.keycode <= KEY_3:
			_on_number_key(k.keycode - KEY_1)
		elif k.pressed and not k.echo and k.keycode == KEY_F5:
			_save()
		elif k.pressed and not k.echo and k.keycode == KEY_F9:
			_load()

func _on_number_key(n: int) -> void:
	# Build-bar drill-down (AoE2-style): with the bar closed, 1/2/3 open the
	# Econ/Military/Wonder rows. While a row is open, the digits pick a building
	# from that row instead of re-opening a category.
	if _menu == null:
		return
	if _menu._bar_depth >= 1:
		_menu.bar_select_item(n)
	else:
		_menu.toggle_bar_category(n)

func _on_escape() -> void:
	if _menu == null:
		return
	if _menu.radial.is_open():
		_menu.pop_radial()
	elif _menu._bar_depth > 0:
		_menu.pop_bar()
	else:
		_menu.cancel_pending()

func _on_menu_feedback(text: String) -> void:
	if text == "save_requested":
		_save()
		return
	if _hud_label != null:
		_hud_label.text = text
	# Restore the normal HUD line shortly after transient feedback.
	await get_tree().create_timer(2.0).timeout
	_update_hud()

func _spawn_soldier() -> void:
	# Train a soldier near the commander (S key).
	if _combat == null or _commander == null:
		return
	var fwd: Vector3 = -_commander.global_transform.basis.z
	fwd.y = 0.0
	if fwd.length() < 0.1:
		fwd = Vector3(1, 0, 0)
	var spot: Vector3 = _commander.position + fwd.normalized() * 3.0
	var gy: int = _world.shard.get_height(int(spot.x), int(spot.z))
	_combat.spawn_soldier(Vector3(spot.x, gy, spot.z), 0, &"player", "stone")

func _research_next() -> void:
	# T researches the first affordable tech in the current age.
	if _age == null:
		return
	for tid in _age.available_techs():
		if _age.research(tid, _units):
			print("[main] researched %s" % tid)
			return
	print("[main] no affordable tech right now")

func _on_building_claim(kind: StringName, tile: Vector3i) -> void:
	if _territory != null:
		_territory.add_claim(tile.x, tile.z, kind)
	if _age != null:
		_age.record_building(kind)

func _on_age_advanced(new_age: int) -> void:
	print("[main] advanced to age %d" % new_age)

func _save() -> void:
	if _world == null or _units == null:
		return
	var seed_now: int = int(_get_flag_arg("--seed=")) if not _get_flag_arg("--seed=").is_empty() else 12345
	if SaveGame.save(_world, _units, seed_now):
		print("[main] saved game")

func _load() -> void:
	var data: Dictionary = SaveGame.load_save()
	if data.is_empty():
		print("[main] no save to load")
		return
	SaveGame.apply_resources(data)
	print("[main] loaded resources from save")

func _process(_delta: float) -> void:
	# Hold-Tab radial menu: open on press, confirm hovered wedge on release.
	if _menu != null:
		if Input.is_action_just_pressed("radial_menu"):
			_menu.open_radial()
		elif Input.is_action_just_released("radial_menu"):
			_menu.release_radial()
		# Track even without motion events so the wedge under a still mouse
		# highlights the instant the menu opens.
		if Input.is_action_pressed("radial_menu") and _menu.radial.is_open():
			_menu.track_radial(get_viewport().get_mouse_position())
		# F-mode drives the commander with WASD instead of click-to-move.
		if _commander != null:
			_commander.f_mode = _menu.mouse_mode == &"fmode"
	# Fog reveal from living units each frame (cheap enough at this scale).
	if _fog == null or _units == null:
		return
	var sources: Array = []
	if is_instance_valid(_commander):
		sources.append({"x": int(_commander.position.x), "z": int(_commander.position.z), "radius": 10})
	for p in _units.peasants:
		if is_instance_valid(p):
			sources.append({"x": int(p.position.x), "z": int(p.position.z), "radius": 7})
	_fog.refresh_visibility(sources)

	# AI + win conditions (cheap checks each frame).
	if _ai != null and _commander != null:
		_ai.tick(_commander.position)
	if _wincon != null:
		var defeated: StringName = _wincon.check_conquest(&"enemy", true, _combat.soldiers_for(&"enemy").size())
		if defeated != &"":
			_on_civ_won(&"player", WinConditions.CONQUEST)
	# Season clock + HUD refresh.
	if _season != null:
		_season.tick(_delta)
		if Engine.get_process_frames() % 30 == 0:
			_update_hud()

func _on_civ_won(civ: StringName, condition: StringName) -> void:
	if _hud_label != null:
		_hud_label.text = "VICTORY — %s wins by %s!" % [civ, condition]
	print("[main] %s wins by %s" % [civ, condition])

func _on_season_ended(n: int) -> void:
	# Archive the current leader and roll the season.
	var leader: StringName = &"player"
	var prestige: int = _wincon.prestige_score(leader) if _wincon != null else 0
	_season.reset_for_next(leader, WinConditions.PRESTIGE, prestige, {})
	print("[main] season %d ended -> season %d begins (champion archived)" % [n, _season.season_number])

func _dig_at(pos: Vector3) -> void:
	# Right-click digs the clicked column (mine/harvest/dig terrain live).
	if _world == null:
		return
	_world.dig(int(pos.x), int(pos.z), 1)

func _raise_at(pos: Vector3) -> void:
	if _world == null:
		return
	_world.raise(int(pos.x), int(pos.z), 1, 2)

func _order_dig(pos: Vector3) -> void:
	# Right-click: nearest free peasant digs/mines the clicked column and hauls
	# the material home. Stone ground -> stone, anything else -> dirt.
	if _world == null or _units == null:
		return
	var x: int = int(pos.x)
	var z: int = int(pos.z)
	var kind: StringName = &"stone" if _world.shard.surface_material(x, z) == 3 else &"dirt"
	var best: Peasant = null
	var best_d: float = INF
	for p in _units.peasants:
		if not is_instance_valid(p) or p.carrying > 0:
			continue
		var d: float = p.position.distance_squared_to(pos)
		if d < best_d:
			best_d = d
			best = p
	if best != null:
		best.order_dig(pos, kind)

func _place_house() -> void:
	# Place a house foundation a few tiles ahead of the commander and send the
	# nearest peasants to haul materials and build it.
	if _buildings == null or _commander == null:
		return
	var fwd: Vector3 = -_commander.global_transform.basis.z
	fwd.y = 0.0
	if fwd.length() < 0.1:
		fwd = Vector3(1, 0, 0)
	var spot: Vector3 = _commander.position + fwd.normalized() * 6.0
	var tile := Vector3i(int(spot.x), 0, int(spot.z))
	var site: ConstructionSite = _buildings.place(&"house", tile, &"player")
	# Send the 3 nearest idle-ish peasants to haul+build.
	var peasants: Array = _units.peasants.duplicate()
	peasants.sort_custom(func(a: Peasant, b: Peasant) -> bool:
		return a.position.distance_squared_to(site.position) < b.position.distance_squared_to(site.position))
	var sent: int = 0
	for p in peasants:
		if sent >= 3:
			break
		if p.carrying > 0:
			continue
		p.order_haul(site, _depot)
		sent += 1

func _terrain_click(screen_pos: Vector2) -> Variant:
	var cam := _camera.get_node("Camera3D") as Camera3D
	if cam == null:
		return null
	var origin: Vector3 = cam.project_ray_origin(screen_pos)
	var dir: Vector3 = cam.project_ray_normal(screen_pos)
	var space: PhysicsDirectSpaceState3D = _commander.get_world_3d().direct_space_state
	var query := PhysicsRayQueryParameters3D.create(origin, origin + dir * 500.0)
	var hit: Dictionary = space.intersect_ray(query)
	if hit.is_empty():
		return null
	return hit["position"]

func _on_cargo_changed(_amount: int, _capacity: int) -> void:
	_update_hud()

func _update_hud() -> void:
	if _hud_label == null:
		return
	var cargo_text := ""
	if _commander != null:
		cargo_text = " · cargo %d/%d" % [_commander.cargo, Commander.CARGO_CAPACITY]
	var season_text := ""
	if _season != null:
		season_text = " · S%d d%d" % [_season.season_number, int(_season.elapsed_days)]
	_hud_label.text = "CraftPires — TAB menu · 1/2/3 build · LMB move · Shift+LMB beam · RMB dig · T tech · F5/F9" + cargo_text + season_text
