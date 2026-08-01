class_name RadialMenu
extends Control
## Hold-to-open pie menu. Centered on screen; the mouse flicks toward a wedge and
## releasing the open key confirms the hovered item. Items can open a sub-level
## (drill-down) or emit `action_chosen` with a payload. Drawn with polygons — no art.

signal action_chosen(id: StringName, payload: Variant)
signal closed

const RADIUS: float = 150.0
const DEAD_ZONE: float = 26.0        # px from center that counts as "no selection"
const WEDGE_GAP: float = 0.06        # radians trimmed off each wedge edge

var _level_stack: Array = []         # each entry: {"title": String, "items": Array}
var _hover: int = -1
var _center: Vector2 = Vector2.ZERO  # on-screen anchor (cursor at open), clamped

func _ready() -> void:
	visible = false
	set_anchors_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE

func open(root: Dictionary, at: Vector2 = Vector2.INF) -> void:
	_level_stack = [root]
	_hover = -1
	visible = true
	# Anchor at the cursor (or viewport center when not given), clamped so the
	# whole ring stays on screen regardless of window size.
	var vp: Vector2 = get_viewport_rect().size
	_center = at if at != Vector2.INF else vp * 0.5
	_center.x = clampf(_center.x, RADIUS + 8.0, vp.x - RADIUS - 8.0)
	_center.y = clampf(_center.y, RADIUS + 8.0, vp.y - RADIUS - 8.0)
	queue_redraw()

func close() -> void:
	visible = false
	_level_stack.clear()
	_hover = -1
	closed.emit()
	queue_redraw()

func is_open() -> bool:
	return visible

func current() -> Dictionary:
	return _level_stack.back() if not _level_stack.is_empty() else {}

func _item_count() -> int:
	return (current().get("items", []) as Array).size()

## Track the mouse while the open key is held. Returns the hovered index.
func track(mouse_pos: Vector2) -> int:
	var rel: Vector2 = mouse_pos - _center
	if rel.length() < DEAD_ZONE:
		_hover = -1
		queue_redraw()
		return _hover
	var count: int = _item_count()
	if count == 0:
		return -1
	# Angle from +X axis, mapped so wedge 0 sits at the top.
	var ang: float = atan2(rel.y, rel.x) + PI * 0.5
	if ang < 0.0:
		ang += TAU
	var sector: float = TAU / float(count)
	_hover = clampi(int(ang / sector), 0, count - 1)
	queue_redraw()
	return _hover

## Confirm the current hover. Drill into sub-menus, otherwise emit the action.
func confirm_hover() -> void:
	var items: Array = current().get("items", [])
	if _hover < 0 or _hover >= items.size():
		close()
		return
	var item: Dictionary = items[_hover]
	if item.has("submenu"):
		_level_stack.append(item["submenu"])
		_hover = -1
		queue_redraw()
		return
	var id: StringName = item.get("id", &"")
	var payload: Variant = item.get("payload", null)
	close()
	action_chosen.emit(id, payload)

func pop_level() -> void:
	if _level_stack.size() > 1:
		_level_stack.pop_back()
		_hover = -1
		queue_redraw()

func _draw() -> void:
	if not is_open():
		return
	var center: Vector2 = _center
	var cur: Dictionary = current()
	var items: Array = cur.get("items", [])
	var count: int = items.size()
	if count == 0:
		return
	var sector: float = TAU / float(count)
	for i in count:
		var a0: float = -PI * 0.5 + float(i) * sector + WEDGE_GAP
		var a1: float = -PI * 0.5 + float(i + 1) * sector - WEDGE_GAP
		var col: Color = Color(0.10, 0.11, 0.14, 0.92) if i != _hover else Color(0.85, 0.60, 0.18, 0.96)
		_draw_wedge(center, a0, a1, col)
		# Label at wedge midpoint.
		var mid: float = (a0 + a1) * 0.5
		var label_pos: Vector2 = center + Vector2(cos(mid), sin(mid)) * (RADIUS * 0.62)
		var text: String = str(items[i].get("label", ""))
		_draw_centered_text(text, label_pos, Color.WHITE if i != _hover else Color.BLACK)
	# Center hub shows the current level title / breadcrumb.
	draw_circle(center, DEAD_ZONE - 4.0, Color(0.06, 0.07, 0.09, 0.95))
	var title: String = str(cur.get("title", "Menu"))
	if _level_stack.size() > 1:
		title = "< " + title
	_draw_centered_text(title, center + Vector2(0, RADIUS + 18.0), Color(1, 1, 1, 0.85))

func _draw_wedge(center: Vector2, a0: float, a1: float, col: Color) -> void:
	var pts := PackedVector2Array()
	pts.append(center)
	var steps: int = 14
	for s in range(steps + 1):
		var a: float = lerpf(a0, a1, float(s) / float(steps))
		pts.append(center + Vector2(cos(a), sin(a)) * RADIUS)
	draw_colored_polygon(pts, col)

func _draw_centered_text(text: String, at: Vector2, col: Color) -> void:
	var font: Font = get_theme_default_font()
	var fs: int = 16
	var w: float = font.get_string_size(text, HORIZONTAL_ALIGNMENT_CENTER, -1, fs).x
	draw_string(font, at - Vector2(w * 0.5, -fs * 0.35), text, HORIZONTAL_ALIGNMENT_CENTER, -1, fs, col)
