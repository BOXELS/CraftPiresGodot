class_name HelpSheet
extends CanvasLayer
## Toggleable commands help (H). Readable categories — not a dense run-on
## like the early Three.js sheet. Esc / H closes.

var _panel: PanelContainer
var _open: bool = false

func _ready() -> void:
	layer = 20
	_panel = PanelContainer.new()
	_panel.visible = false
	_panel.custom_minimum_size = Vector2(480, 0)
	add_child(_panel)
	# Anchor top-right-ish so it doesn't cover the resource HUD.
	_panel.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	_panel.position = Vector2(-500, 56)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 16)
	margin.add_theme_constant_override("margin_right", 16)
	margin.add_theme_constant_override("margin_top", 12)
	margin.add_theme_constant_override("margin_bottom", 12)
	_panel.add_child(margin)

	var vb := VBoxContainer.new()
	vb.add_theme_constant_override("separation", 6)
	margin.add_child(vb)

	var title := Label.new()
	title.text = "Commands  (H to hide)"
	title.add_theme_font_size_override("font_size", 18)
	title.add_theme_color_override("font_color", Color(0.95, 0.80, 0.45))
	vb.add_child(title)

	for line in _lines():
		var row := Label.new()
		row.text = line
		row.add_theme_font_size_override("font_size", 13)
		row.add_theme_color_override("font_color", Color(0.92, 0.93, 0.95, 0.92))
		vb.add_child(row)

func _lines() -> PackedStringArray:
	return PackedStringArray([
		"",
		"Select",
		"  LMB · click unit   · drag box   · Shift+LMB toggle",
		"  LMB×2 · same type on screen",
		"  Tab · commander   · . idle peasant   · Ctrl+A all peasants",
		"",
		"Command",
		"  RMB · move (formation)   · on site = build",
		"  Shift+RMB · queue waypoint",
		"  Shift+LMB · work (gather / dig / hunt / beam)",
		"  Esc / RMB · cancel place or pave",
		"",
		"Build",
		"  1 Settlement · 2 Defense · 3 Crafting",
		"  folders: House / Storage / Roads (Esc backs out)",
		"  Dirt Road · drag to paint (+35% speed)",
		"",
		"Other",
		"  F · possess selected unit (WASD + mouse look · F/Esc release)",
		"  Hold Tab · radial menu   · H help   · F5 save · F9 load",
	])

func toggle() -> void:
	_open = not _open
	_panel.visible = _open

func is_open() -> bool:
	return _open

func close() -> void:
	_open = false
	_panel.visible = false
