class_name BuildBar
extends Control
## AoE2 / Three.js MVP bottom build bar. Always visible at the bottom center.
## Top level shows Settlement / Defense / Crafting; drilling swaps the row in
## place (Back + crumb + items). Folders (House, Storage, Roads) drill one more
## level. Number-key hotkeys are handled by MenuController; this draws + clicks.

signal group_pressed(group_id: StringName)
signal folder_pressed(folder_id: StringName, children: Array)
signal item_pressed(entry: Dictionary)
signal back_pressed

const BTN_MIN_W: float = 104.0
const BTN_H: float = 64.0

var _row: HBoxContainer
var _group: StringName = &""
var _folder_id: StringName = &""
var _folder_items: Array = []
var _active_kind: StringName = &""
var _pave_active: bool = false

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	offset_top = -96.0
	offset_bottom = -16.0
	offset_left = 0.0
	offset_right = 0.0

	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(center)

	_row = HBoxContainer.new()
	_row.add_theme_constant_override("separation", 10)
	_row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	center.add_child(_row)
	rebuild()

func set_active_kind(kind: StringName) -> void:
	_active_kind = kind
	rebuild()

func set_pave_active(on: bool) -> void:
	_pave_active = on
	rebuild()

func open_group(group_id: StringName) -> void:
	_group = group_id
	_folder_id = &""
	_folder_items = []
	rebuild()

func open_folder(folder_id: StringName, children: Array) -> void:
	_folder_id = folder_id
	_folder_items = children
	rebuild()

func close_to_top() -> void:
	_group = &""
	_folder_id = &""
	_folder_items = []
	rebuild()

func pop() -> bool:
	if _folder_id != &"":
		_folder_id = &""
		_folder_items = []
		rebuild()
		return true
	if _group != &"":
		_group = &""
		rebuild()
		return true
	return false

func current_group() -> StringName:
	return _group

func in_folder() -> bool:
	return _folder_id != &""

func rebuild() -> void:
	if _row == null:
		return
	for c in _row.get_children():
		c.queue_free()
	# Defer building so free'd nodes are gone.
	call_deferred("_rebuild_now")

func _rebuild_now() -> void:
	if _row == null:
		return
	for c in _row.get_children():
		c.free()
	if _group == &"":
		_build_top()
	elif _folder_id != &"":
		_build_folder()
	else:
		_build_group()

func _build_top() -> void:
	var rows: Dictionary = ShortcutMenus.build_bar_rows()
	var i: int = 0
	for gid in [&"settlement", &"defense", &"crafting"]:
		i += 1
		var g: Dictionary = rows.get(gid, {})
		var sub: String = _group_subtitle(gid)
		var btn := _make_btn(str(g.get("label", gid)), sub, "[%d]" % i, false)
		var captured: StringName = gid
		btn.pressed.connect(func(): group_pressed.emit(captured))
		_row.add_child(btn)

func _group_subtitle(gid: StringName) -> String:
	match gid:
		&"settlement":
			return "Keep · House · Storage · Roads"
		&"defense":
			return "Watchtower"
		&"crafting":
			return "Hall · Smiths"
		_:
			return ""

func _build_group() -> void:
	var rows: Dictionary = ShortcutMenus.build_bar_rows()
	var g: Dictionary = rows.get(_group, {})
	_row.add_child(_make_back("← Back", str(g.get("label", "")), "[Esc]"))
	_row.add_child(_make_crumb(str(g.get("label", ""))))
	var items: Array = g.get("items", [])
	for i in items.size():
		_append_entry(items[i], i + 1)

func _build_folder() -> void:
	var rows: Dictionary = ShortcutMenus.build_bar_rows()
	var g: Dictionary = rows.get(_group, {})
	var folder_label: String = str(_folder_id).replace("folder_", "").capitalize()
	_row.add_child(_make_back("← %s" % str(g.get("label", "")), folder_label, "[Esc]"))
	_row.add_child(_make_crumb("%s › %s" % [str(g.get("label", "")), folder_label]))
	for i in _folder_items.size():
		_append_entry(_folder_items[i], i + 1)

func _append_entry(entry: Dictionary, hotkey: int) -> void:
	var id: StringName = entry.get("id", &"")
	var label: String = str(entry.get("label", id))
	if entry.has("children"):
		var btn := _make_btn(label, "…", "[%d]" % hotkey, false)
		var kids: Array = entry["children"]
		var fid: StringName = id
		btn.pressed.connect(func(): folder_pressed.emit(fid, kids))
		_row.add_child(btn)
		return
	var cost: String = _cost_label(entry)
	var active: bool = (entry.get("pave", false) and _pave_active) or (id == _active_kind)
	var btn2 := _make_btn(label, cost, "[%d]" % hotkey, active)
	var captured: Dictionary = entry
	btn2.pressed.connect(func(): item_pressed.emit(captured))
	_row.add_child(btn2)

func _cost_label(entry: Dictionary) -> String:
	if entry.get("pave", false):
		return "%dd · +35%% speed" % MaterialInteractions.DIRT_ROAD_COST
	var kind: StringName = entry.get("id", &"")
	var bom: Dictionary = BuildingDefs.bom(kind)
	if bom.is_empty():
		return ""
	var parts: PackedStringArray = PackedStringArray()
	if int(bom.get(&"wood", 0)) > 0:
		parts.append("%dw" % int(bom[&"wood"]))
	if int(bom.get(&"stone", 0)) > 0:
		parts.append("%ds" % int(bom[&"stone"]))
	if int(bom.get(&"food", 0)) > 0:
		parts.append("%df" % int(bom[&"food"]))
	return " ".join(parts)

func _make_back(title: String, sub: String, key: String) -> Button:
	var btn := _make_btn(title, sub, key, false)
	btn.pressed.connect(func(): back_pressed.emit())
	# Slightly dimmer back button (MVP buildback style).
	var sb := btn.get_theme_stylebox("normal").duplicate() as StyleBoxFlat
	if sb:
		sb.bg_color = Color(0.06, 0.07, 0.09, 0.72)
		btn.add_theme_stylebox_override("normal", sb)
	return btn

func _make_crumb(text: String) -> Label:
	var lab := Label.new()
	lab.text = text.to_upper()
	lab.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	lab.add_theme_font_size_override("font_size", 11)
	lab.add_theme_color_override("font_color", Color(1, 1, 1, 0.45))
	lab.custom_minimum_size = Vector2(0, BTN_H)
	return lab

func _make_btn(title: String, sub: String, key: String, active: bool) -> Button:
	var btn := Button.new()
	btn.custom_minimum_size = Vector2(BTN_MIN_W, BTN_H)
	btn.focus_mode = Control.FOCUS_NONE
	btn.mouse_filter = Control.MOUSE_FILTER_STOP
	btn.text = "%s\n%s\n%s" % [title, sub, key]
	btn.alignment = HORIZONTAL_ALIGNMENT_CENTER
	btn.add_theme_font_size_override("font_size", 12)
	btn.add_theme_color_override("font_color", Color(0.95, 0.96, 0.98))
	btn.add_theme_color_override("font_hover_color", Color(1, 1, 1))
	var normal := StyleBoxFlat.new()
	normal.bg_color = Color(0.10, 0.11, 0.14, 0.88) if not active else Color(0.85, 0.60, 0.18, 0.28)
	normal.border_color = Color(1, 1, 1, 0.14) if not active else Color(0.95, 0.80, 0.45, 0.95)
	normal.set_border_width_all(1)
	normal.set_corner_radius_all(10)
	normal.content_margin_left = 12
	normal.content_margin_right = 12
	normal.content_margin_top = 8
	normal.content_margin_bottom = 8
	var hover := normal.duplicate() as StyleBoxFlat
	hover.border_color = Color(0.95, 0.80, 0.45, 0.85)
	hover.bg_color = Color(0.14, 0.15, 0.18, 0.92)
	btn.add_theme_stylebox_override("normal", normal)
	btn.add_theme_stylebox_override("hover", hover)
	btn.add_theme_stylebox_override("pressed", hover)
	return btn
