class_name CameraRig
extends Node3D
## RTS camera: WASD/arrow pan, Q/E rotate, wheel zoom (pitch tied), MMB drag-pan.
## Camera child sits at boom length looking down; rig yaw-rotates around target.

@export var pan_speed: float = 24.0
@export var rotate_speed: float = 1.8
@export var zoom_min: float = 12.0
@export var zoom_max: float = 90.0
@export var zoom_step: float = 6.0
@export var pitch_min: float = 35.0
@export var pitch_max: float = 70.0

var _zoom: float = 40.0
var _drag_panning: bool = false
var _camera: Camera3D

func _ready() -> void:
	_camera = Camera3D.new()
	_camera.name = "Camera3D"
	add_child(_camera)
	_camera.current = true
	_apply_boom()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mb := event as InputEventMouseButton
		match mb.button_index:
			MOUSE_BUTTON_WHEEL_UP:
				if mb.pressed:
					_zoom = clampf(_zoom - zoom_step, zoom_min, zoom_max)
					_apply_boom()
			MOUSE_BUTTON_WHEEL_DOWN:
				if mb.pressed:
					_zoom = clampf(_zoom + zoom_step, zoom_min, zoom_max)
					_apply_boom()
			MOUSE_BUTTON_MIDDLE:
				_drag_panning = mb.pressed
	elif event is InputEventMouseMotion and _drag_panning:
		var mm := event as InputEventMouseMotion
		# Drag the world with the mouse: move opposite the drag, in camera space.
		var cam_basis := global_transform.basis
		var right: Vector3 = cam_basis.x
		var forward: Vector3 = -cam_basis.z
		var drag_scale: float = _zoom / 600.0
		position += (right * -mm.relative.x + forward * -mm.relative.y) * drag_scale

func _process(delta: float) -> void:
	var pan := Vector3.ZERO
	if Input.is_action_pressed("cam_pan_up"):
		pan.z -= 1.0
	if Input.is_action_pressed("cam_pan_down"):
		pan.z += 1.0
	if Input.is_action_pressed("cam_pan_left"):
		pan.x -= 1.0
	if Input.is_action_pressed("cam_pan_right"):
		pan.x += 1.0
	if pan != Vector3.ZERO:
		pan = pan.normalized()
		var cam_basis := global_transform.basis
		# Camera-basis pan: right is basis.x, forward is -basis.z projected flat.
		var right: Vector3 = cam_basis.x
		var forward: Vector3 = -cam_basis.z
		forward.y = 0.0
		forward = forward.normalized()
		position += (right * pan.x + forward * -pan.z) * pan_speed * delta * (_zoom / 40.0)

	if Input.is_action_pressed("cam_rotate_left"):
		rotate_y(rotate_speed * delta)
	if Input.is_action_pressed("cam_rotate_right"):
		rotate_y(-rotate_speed * delta)

func _apply_boom() -> void:
	# Zoom controls boom length; pitch eases between min (far) and max (near).
	var t: float = inverse_lerp(zoom_max, zoom_min, _zoom)
	var pitch: float = lerpf(pitch_min, pitch_max, clampf(t, 0.0, 1.0))
	_camera.position = Vector3(0.0, _zoom * sin(deg_to_rad(pitch)), _zoom * cos(deg_to_rad(pitch)))
	_camera.rotation_degrees = Vector3(-pitch, 0.0, 0.0)

func focus_on(world_pos: Vector3) -> void:
	position = Vector3(world_pos.x, 0.0, world_pos.z)
