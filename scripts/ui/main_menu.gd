class_name MainMenu
extends CanvasLayer
## Title screen shown over the live world (which sims behind it as a backdrop).
## Single Player starts the game; Vs Bots / Multiplayer are placeholders.

signal start_single_player

var _root: Control
var _panel: PanelContainer

func _ready() -> void:
	layer = 100
	_root = Control.new()
	_root.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(_root)

	# Dim backdrop so the menu reads over the world.
	var dim := ColorRect.new()
	dim.color = Color(0.04, 0.05, 0.08, 0.55)
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	_root.add_child(dim)

	_panel = PanelContainer.new()
	_panel.custom_minimum_size = Vector2(420, 0)
	_root.add_child(_panel)
	_panel.set_anchors_preset(Control.PRESET_CENTER)
	# Center the panel.
	_panel.position = (get_viewport().get_visible_rect().size - _panel.custom_minimum_size) * 0.5

	var vb := VBoxContainer.new()
	vb.add_theme_constant_override("separation", 14)
	_panel.add_child(vb)

	var title := Label.new()
	title.text = "CRAFTPIRES"
	title.add_theme_font_size_override("font_size", 44)
	title.add_theme_color_override("font_color", Color(0.95, 0.80, 0.45))
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vb.add_child(title)

	var sub := Label.new()
	sub.text = "AoE II · Settlers · Empire Earth · Minecraft"
	sub.add_theme_font_size_override("font_size", 13)
	sub.add_theme_color_override("font_color", Color(1, 1, 1, 0.6))
	sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vb.add_child(sub)

	vb.add_child(HSeparator.new())

	var btn_sp := _make_button("Single Player")
	btn_sp.pressed.connect(_on_single_player)
	vb.add_child(btn_sp)

	var btn_bots := _make_button("Vs Bots  (soon)")
	btn_bots.disabled = true
	vb.add_child(btn_bots)

	var btn_mp := _make_button("Multiplayer  (soon)")
	btn_mp.disabled = true
	vb.add_child(btn_mp)

	vb.add_child(HSeparator.new())
	var hint := Label.new()
	hint.text = "TAB radial menu · 1/2/3 build · H help"
	hint.add_theme_font_size_override("font_size", 11)
	hint.add_theme_color_override("font_color", Color(1, 1, 1, 0.45))
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vb.add_child(hint)

func _make_button(text: String) -> Button:
	var b := Button.new()
	b.text = text
	b.custom_minimum_size = Vector2(0, 44)
	b.add_theme_font_size_override("font_size", 18)
	return b

func _on_single_player() -> void:
	hide_menu()
	start_single_player.emit()

func hide_menu() -> void:
	_root.visible = false

func is_open() -> bool:
	return _root.visible
