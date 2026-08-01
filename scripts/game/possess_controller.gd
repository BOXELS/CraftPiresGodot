class_name PossessController
extends Node
## First-person possession (F). Select one unit, press F — WASD walks, mouse
## looks, F/Esc releases. Improvement vs Three.js: clean mouse capture via
## Input.MOUSE_MODE_CAPTURED with no pointer-lock failure spiral.

signal entered(unit: Node3D)
signal exited(unit: Node3D)

var camera_rig: CameraRig
var active: Node3D = null
var _yaw: float = 0.0
var _pitch: float = -0.12
var _cam: Camera3D

const EYE_HEIGHT_CMD: float = 1.55
const EYE_HEIGHT_PEASANT: float = 1.15
const LOOK_SENS: float = 0.0032

func setup(p_camera: CameraRig) -> void:
	camera_rig = p_camera

func is_active() -> bool:
	return active != null and is_instance_valid(active)

func toggle(unit: Node3D) -> void:
	if is_active():
		exit()
	elif unit != null:
		enter(unit)

func enter(unit: Node3D) -> void:
	if unit == null or not is_instance_valid(unit):
		return
	if is_active():
		exit()
	active = unit
	_cam = camera_rig.get_node_or_null("Camera3D") as Camera3D
	if _cam == null:
		active = null
		return
	_yaw = camera_rig.rotation.y
	_pitch = -0.12
	# Stop the unit's AI while possessed.
	if unit is Peasant:
		(unit as Peasant).order_idle()
		(unit as Peasant).has_move_target = false
		if (unit as Peasant).rig != null:
			(unit as Peasant).rig.visible = false
	elif unit is Commander:
		(unit as Commander).f_mode = true
		(unit as Commander).has_target = false
		(unit as Commander).beaming = false
		if (unit as Commander).rig != null:
			(unit as Commander).rig.visible = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	entered.emit(unit)

func exit() -> void:
	if not is_active():
		return
	var u: Node3D = active
	active = null
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	if u is Commander and is_instance_valid(u):
		(u as Commander).f_mode = false
		if (u as Commander).rig != null:
			(u as Commander).rig.visible = true
	elif u is Peasant and is_instance_valid(u):
		if (u as Peasant).rig != null:
			(u as Peasant).rig.visible = true
	# Hand the RTS camera back over the unit.
	if camera_rig != null and is_instance_valid(u):
		camera_rig.rotation.y = _yaw
		camera_rig.focus_on(u.global_position)
	exited.emit(u)

func _unhandled_input(event: InputEvent) -> void:
	if not is_active():
		return
	if event is InputEventMouseMotion:
		var mm := event as InputEventMouseMotion
		_yaw -= mm.relative.x * LOOK_SENS
		_pitch = clampf(_pitch - mm.relative.y * LOOK_SENS, -1.25, 1.25)
		get_viewport().set_input_as_handled()

func _process(delta: float) -> void:
	if not is_active() or _cam == null:
		return
	var u: Node3D = active
	var eye_h: float = EYE_HEIGHT_CMD if u is Commander else EYE_HEIGHT_PEASANT
	# Drive the unit with WASD relative to look yaw.
	var fwd := Vector3(sin(_yaw), 0.0, cos(_yaw))
	var rgt := Vector3(fwd.z, 0.0, -fwd.x)
	var wish := Vector3.ZERO
	if Input.is_action_pressed("cam_pan_up"):
		wish += fwd
	if Input.is_action_pressed("cam_pan_down"):
		wish -= fwd
	if Input.is_action_pressed("cam_pan_left"):
		wish -= rgt
	if Input.is_action_pressed("cam_pan_right"):
		wish += rgt
	if wish.length() > 0.01:
		wish = wish.normalized()
		var speed: float = Commander.SPEED if u is Commander else (u as Peasant).move_speed()
		u.global_position += wish * speed * delta
		var sh: VoxelShard = null
		if u is Peasant:
			sh = (u as Peasant).shard
		elif u is Commander:
			sh = (u as Commander).shard
		if sh != null:
			u.position.y = float(sh.get_height(int(floor(u.position.x)), int(floor(u.position.z))))
		u.rotation.y = atan2(wish.x, wish.z)
	# Place the camera at the unit's eyes looking along yaw/pitch.
	var eye: Vector3 = u.global_position + Vector3(0, eye_h, 0)
	var look_dir := Vector3(sin(_yaw) * cos(_pitch), sin(_pitch), cos(_yaw) * cos(_pitch))
	_cam.global_transform = Transform3D(Basis.looking_at(look_dir, Vector3.UP), eye)
