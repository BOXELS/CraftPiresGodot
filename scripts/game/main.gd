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

	var shot_path: String = _get_flag_arg("--screenshot=")
	if not shot_path.is_empty():
		if OS.get_cmdline_user_args().has("--quarry-demo"):
			_frame_at(Vector3(58, 0, 74), 34.0)
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
	elif event is InputEventKey:
		var k := event as InputEventKey
		if k.pressed and not k.echo and k.keycode == KEY_B:
			_place_house()

func _dig_at(pos: Vector3) -> void:
	# Right-click digs the clicked column (mine/harvest/dig terrain live).
	if _world == null:
		return
	_world.dig(int(pos.x), int(pos.z), 1)

func _raise_at(pos: Vector3) -> void:
	# Shift+Right-click raises the clicked column with dirt.
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
	_hud_label.text = "CraftPires — LMB move · Shift+LMB beam · RMB peasant-dig · Ctrl+RMB carve · Shift+RMB raise · B build" + cargo_text
