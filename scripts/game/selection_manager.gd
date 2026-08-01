class_name SelectionManager
extends Node3D
## AoE2-style selection: click to select one, drag a box for many, Shift adds /
## toggles, double-click selects all of the same kind on screen. Owns the set of
## selected units + the selection rings under them, and emits changes so the HUD
## / command layer can react.

signal selection_changed(units: Array)

const DOUBLE_CLICK_MS: int = 480

var units: UnitManager
var commander: Commander
var camera_rig: CameraRig

var selected: Array = []            # Array of Node3D (Peasant / Commander / Soldier)
var _rings: Dictionary = {}         # unit instance_id -> MeshInstance3D ring
var _last_click_unit: int = -1
var _last_click_at: int = 0

func setup(p_units: UnitManager, p_commander: Commander, p_camera: CameraRig) -> void:
	units = p_units
	commander = p_commander
	camera_rig = p_camera

func is_selected(u: Node3D) -> bool:
	return selected.has(u)

func clear() -> void:
	_apply_selection(selected.duplicate(), [])

func select_only(u: Node3D) -> void:
	_apply_selection(selected.duplicate(), [u])

func set_selection(list: Array) -> void:
	_apply_selection(selected.duplicate(), list)

func toggle(u: Node3D) -> void:
	var next: Array = selected.duplicate()
	if next.has(u):
		next.erase(u)
	else:
		next.append(u)
	_apply_selection(selected.duplicate(), next)

func _apply_selection(old: Array, next: Array) -> void:
	for u in old:
		if is_instance_valid(u) and not next.has(u):
			_remove_ring(u)
	selected = next
	for u in selected:
		if is_instance_valid(u):
			_add_ring(u)
	selection_changed.emit(selected)

func count() -> int:
	return selected.size()

func peasants() -> Array:
	return selected.filter(func(u): return u is Peasant)

func soldiers() -> Array:
	return selected.filter(func(u): return u is Soldier)

func has_commander() -> bool:
	return commander != null and selected.has(commander)

## All selectable units (peasants + commander + player soldiers).
func all_units() -> Array:
	var out: Array = []
	for p in units.peasants:
		if is_instance_valid(p):
			out.append(p)
	if is_instance_valid(commander):
		out.append(commander)
	return out

## Double-click: select every on-screen unit of the same class as `proto`.
func select_same_on_screen(proto: Node3D) -> void:
	var cam := _camera()
	if cam == null:
		return
	var cls: String = proto.get_class()
	var matches: Array = []
	for u in all_units():
		if u.get_class() != cls:
			continue
		if _on_screen(cam, u):
			matches.append(u)
	_apply_selection(selected.duplicate(), matches if not matches.is_empty() else [proto])

## Register a click on a unit; returns true if it was a double-click.
func register_click(u: Node3D) -> bool:
	var now: int = Time.get_ticks_msec()
	var id: int = u.get_instance_id()
	var is_double: bool = (id == _last_click_unit) and (now - _last_click_at < DOUBLE_CLICK_MS)
	_last_click_unit = id
	_last_click_at = now
	return is_double

func _camera() -> Camera3D:
	if camera_rig == null:
		return null
	return camera_rig.get_node_or_null("Camera3D") as Camera3D

func _on_screen(cam: Camera3D, u: Node3D) -> bool:
	if cam.is_position_behind(u.global_position):
		return false
	var sp: Vector2 = cam.unproject_position(u.global_position)
	var vp: Vector2 = get_viewport().get_visible_rect().size
	return sp.x >= 0 and sp.x <= vp.x and sp.y >= 0 and sp.y <= vp.y

## Units whose screen position falls inside a drag box.
func units_in_box(rect: Rect2) -> Array:
	var cam := _camera()
	if cam == null:
		return []
	var out: Array = []
	for u in all_units():
		if cam.is_position_behind(u.global_position):
			continue
		var sp: Vector2 = cam.unproject_position(u.global_position)
		if rect.has_point(sp):
			out.append(u)
	return out

# --- Selection rings --------------------------------------------------------

func _add_ring(u: Node3D) -> void:
	var id: int = u.get_instance_id()
	if _rings.has(id):
		return
	var ring := MeshInstance3D.new()
	var mesh := TorusMesh.new()
	mesh.inner_radius = 0.45
	mesh.outer_radius = 0.55
	mesh.rings = 24
	mesh.ring_segments = 8
	ring.mesh = mesh
	var mat := StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.albedo_color = Color(0.35, 0.95, 0.45, 0.9) if u is Peasant else Color(0.95, 0.80, 0.30, 0.95)
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	ring.material_override = mat
	ring.rotation_degrees.x = 90.0   # lay flat on the ground
	ring.position.y = 0.06
	u.add_child(ring)
	_rings[id] = ring

func _remove_ring(u: Node3D) -> void:
	var id: int = u.get_instance_id()
	if _rings.has(id) and is_instance_valid(_rings[id]):
		_rings[id].queue_free()
	_rings.erase(id)
