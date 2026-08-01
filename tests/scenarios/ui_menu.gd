extends ScenarioBase
## Shortcut menus: radial tree data, drill-down navigation, build-bar depth
## logic, and that menu actions reach the game (placement, terraform, modes).

func _init() -> void:
	scenario_name = &"ui_menu"

func setup() -> void:
	# --- Radial tree data is well-formed ---
	var root: Dictionary = ShortcutMenus.radial_root()
	assert_true(root.get("items", []).size() == 3, "radial root has 3 categories")
	var build: Dictionary = root["items"][0]
	assert_true(build.has("submenu"), "Build category opens a submenu")
	var build_items: Array = build["submenu"]["items"]
	assert_true(build_items.size() == 4, "Build submenu lists 4 buildings")
	assert_true(build_items[0].get("payload") == &"house", "first build item is the house")

	# --- MenuController drives navigation + actions headlessly ---
	var world := WorldBuilder.new()
	add_child(world)
	world.build(12345)
	await get_tree().physics_frame

	var units := UnitManager.new()
	add_child(units)
	units.setup(world.shard, world)
	var buildings := BuildingsManager.new()
	add_child(buildings)
	buildings.setup(world.shard)
	var combat := CombatManager.new()
	add_child(combat)
	combat.setup(world.shard)
	var commander := Commander.new()
	add_child(commander)
	commander.setup(world.shard, 0)
	Events.add_resource(&"player", &"wood", 200)
	Events.add_resource(&"player", &"stone", 200)
	var depot := StorageDepot.new(&"player")

	var menu := MenuController.new()
	add_child(menu)
	menu.setup(world, units, buildings, combat, depot, commander)

	# Radial open / drill into Build / select House arms placement.
	menu.open_radial()
	assert_true(menu.radial.is_open(), "radial opens")
	menu.radial._hover = 0                       # Build category
	menu.radial.confirm_hover()                  # drills into Build submenu
	assert_true(menu.radial.is_open(), "submenu keeps menu open")
	assert_true(menu.radial._level_stack.size() == 2, "drilled one level deep")
	menu.radial._hover = 0                       # House
	menu.radial.confirm_hover()
	assert_true(not menu.radial.is_open(), "choosing a leaf closes the radial")
	assert_true(menu.pending_kind == &"house", "selecting House arms house placement")

	# Placement click consumes and places a foundation + spends resources.
	var wood0: int = Events.get_civ_resources(&"player").get(&"wood", 0)
	var consumed: bool = menu.handle_terrain_click(Vector3(40, 0, 40))
	assert_true(consumed, "armed placement consumes the terrain click")
	assert_true(menu.pending_kind == &"", "placement disarmed after click")
	assert_true(buildings.sites.size() == 1, "a construction site was placed")
	var wood1: int = Events.get_civ_resources(&"player").get(&"wood", 0)
	assert_true(wood1 < wood0, "placement spent wood (was %d, now %d)" % [wood0, wood1])

	# Terraform dig action carves the clicked column.
	menu._on_radial_action(&"terraform_dig", null)
	assert_true(menu.pending_terraform == &"dig", "dig mode armed")
	var hx: int = 50
	var hz: int = 50
	var h0: int = world.shard.get_height(hx, hz)
	menu.handle_terrain_click(Vector3(hx, 0, hz))
	assert_true(world.shard.get_height(hx, hz) == h0 - 1, "terraform dig carved one block")

	# Mouse mode toggle flips RTS <-> F-mode.
	assert_true(menu.mouse_mode == &"rts", "mouse starts in RTS mode")
	menu._on_radial_action(&"toggle_mouse_mode", null)
	assert_true(menu.mouse_mode == &"fmode", "toggle switches to F-mode")
	menu._on_radial_action(&"toggle_mouse_mode", null)
	assert_true(menu.mouse_mode == &"rts", "toggle switches back to RTS")

	# Graphics quality applies a real render-scale change.
	menu._on_radial_action(&"gfx_low", null)
	assert_true(menu.graphics_quality == &"low", "graphics quality set to low")
	assert_true(is_equal_approx(get_viewport().scaling_3d_scale, 0.5), "low quality lowers 3D render scale")

	# Build-bar drill-down: open Economy row, then digit picks House.
	menu.toggle_bar_category(0)
	assert_true(menu._bar_depth == 1 and menu._bar_category == &"economy", "digit opens the Economy row")
	menu.bar_select_item(0)
	assert_true(menu.pending_kind == &"house", "row digit selects the house")
	assert_true(menu._bar_depth == 0, "bar closes after selection")
	menu.cancel_pending()

	finish()
