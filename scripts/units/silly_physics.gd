class_name SillyPhysics
extends RefCounted
## Procedural animation for BlendShellRig — poses limbs per frame with math,
## no AnimationPlayer. One instance per unit; call update() each physics frame.

enum Mode { IDLE, WALK, RUN, WORK, CARRY, TUMBLE, WOBBLE }

var mode: Mode = Mode.IDLE
var speed_factor: float = 1.0   # gait frequency multiplier
var wobble_strength: float = 1.0

var _phase: float = 0.0
var _tumble_time: float = 0.0
var _tumble_spin: Vector3 = Vector3.ZERO

func update(rig: BlendShellRig, delta: float, moving_speed: float = 0.0) -> void:
	match mode:
		Mode.IDLE:
			_idle(rig, delta)
		Mode.WALK, Mode.RUN:
			_walk(rig, delta, moving_speed)
		Mode.WORK:
			_work(rig, delta)
		Mode.CARRY:
			_carry(rig, delta, moving_speed)
		Mode.TUMBLE:
			_tumble(rig, delta)
		Mode.WOBBLE:
			_combat_wobble(rig, delta)

func _idle(rig: BlendShellRig, delta: float) -> void:
	_phase += delta * 1.6
	var sway: float = sin(_phase) * 0.04
	rig.pivot_arm_l.rotation.x = sway
	rig.pivot_arm_r.rotation.x = -sway
	rig.pivot_leg_l.rotation.x = 0.0
	rig.pivot_leg_r.rotation.x = 0.0
	rig.torso.position.y = rig.torso.position.y  # keep base height
	rig.torso.rotation.z = sway * 0.5

func _walk(rig: BlendShellRig, delta: float, moving_speed: float) -> void:
	var freq: float = 6.0 * speed_factor * clampf(moving_speed, 0.3, 2.0)
	_phase += delta * freq
	var swing: float = sin(_phase) * 0.6
	rig.pivot_leg_l.rotation.x = swing
	rig.pivot_leg_r.rotation.x = -swing
	rig.pivot_arm_l.rotation.x = -swing * 0.7
	rig.pivot_arm_r.rotation.x = swing * 0.7
	# Bob
	rig.position.y = absf(sin(_phase)) * 0.05
	rig.torso.rotation.z = 0.0

func _work(rig: BlendShellRig, delta: float) -> void:
	_phase += delta * 5.0 * speed_factor
	var chop: float = sin(_phase)
	# Right arm chops; left arm holds.
	rig.pivot_arm_r.rotation.x = -1.4 + chop * 0.9
	rig.pivot_arm_l.rotation.x = -0.4
	rig.torso.rotation.x = chop * 0.08

func _carry(rig: BlendShellRig, delta: float, moving_speed: float) -> void:
	# Arms forward holding a load; still legs-walk.
	_phase += delta * 6.0 * speed_factor * clampf(moving_speed, 0.3, 2.0)
	var swing: float = sin(_phase) * 0.6
	rig.pivot_leg_l.rotation.x = swing
	rig.pivot_leg_r.rotation.x = -swing
	rig.pivot_arm_l.rotation.x = -1.1
	rig.pivot_arm_r.rotation.x = -1.1
	rig.torso.rotation.x = 0.06

func set_airborne(spin: Vector3) -> void:
	# Launch into a tumble (yeet, bodyslam, knockback).
	mode = Mode.TUMBLE
	_tumble_time = 0.0
	_tumble_spin = spin

func _tumble(rig: BlendShellRig, delta: float) -> void:
	_tumble_time += delta
	rig.rotation += _tumble_spin * delta
	# Limbs splay while airborne.
	rig.pivot_arm_l.rotation.z = 0.9
	rig.pivot_arm_r.rotation.z = -0.9
	rig.pivot_leg_l.rotation.x = 0.4
	rig.pivot_leg_r.rotation.x = -0.4

func land(rig: BlendShellRig) -> void:
	# Call when the unit touches ground after a tumble.
	mode = Mode.IDLE
	rig.rotation = Vector3.ZERO
	rig.pivot_arm_l.rotation.z = 0.0
	rig.pivot_arm_r.rotation.z = 0.0

func _combat_wobble(rig: BlendShellRig, delta: float) -> void:
	_phase += delta * 9.0
	var w: float = sin(_phase) * 0.25 * wobble_strength
	rig.pivot_arm_l.rotation.z = w
	rig.pivot_arm_r.rotation.z = -w
	rig.pivot_arm_l.rotation.x = -0.8 + w
	rig.pivot_arm_r.rotation.x = -0.8 - w
	rig.torso.rotation.z = w * 0.4
