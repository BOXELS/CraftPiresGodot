class_name SelectionBox
extends Control
## Screen-space drag rectangle drawn while box-selecting (AoE2). The command
## layer reads `rect` on mouse-up and asks SelectionManager for the units inside.

var dragging: bool = false
var _start: Vector2 = Vector2.ZERO
var _end: Vector2 = Vector2.ZERO

func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	visible = false

func begin(at: Vector2) -> void:
	dragging = true
	_start = at
	_end = at
	visible = true
	queue_redraw()

func update(at: Vector2) -> void:
	if not dragging:
		return
	_end = at
	queue_redraw()

func finish() -> Rect2:
	dragging = false
	visible = false
	queue_redraw()
	return rect()

func cancel() -> void:
	dragging = false
	visible = false
	queue_redraw()

func rect() -> Rect2:
	return Rect2(
		Vector2(minf(_start.x, _end.x), minf(_start.y, _end.y)),
		Vector2(absf(_end.x - _start.x), absf(_end.y - _start.y)))

func is_real_drag() -> bool:
	# Ignore sub-pixel wobble so a plain click still selects a single unit.
	return rect().size.length() > 6.0

func _draw() -> void:
	if not dragging:
		return
	var r := rect()
	draw_rect(r, Color(0.35, 0.95, 0.45, 0.12), true)
	draw_rect(r, Color(0.35, 0.95, 0.45, 0.85), false, 1.5)
