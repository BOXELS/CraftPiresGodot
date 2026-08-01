class_name Commander
extends CharacterBody3D
## The civilization's hero unit. Click-to-move on the voxel terrain, beam-gather
## resources, carry cargo, auto-deposit at the Keep. Uses BlendShellRig +
## SillyPhysics for zero-art visuals and animation.

signal arrived
signal cargo_changed(amount: int, capacity: int)
signal commander_died
signal commander_respawned

const SPEED: float = 4.0
const BEAM_RANGE: float = 3.5
const BEAM_RATE: float = 2.0          # gather ticks per second while beaming
const CARGO_CAPACITY: int = 100
const RESPAWN_TIME: float = 8.0

var civ_id: StringName = &"player"
var cargo: int = 0
var target_position: Vector3 = Vector3.ZERO
var has_target: bool = false
var beaming: bool = false
var beam_target: Vector3 = Vector3.ZERO

var shard: VoxelShard
var rig: BlendShellRig
var anim: SillyPhysics
var beam_mesh: MeshInstance3D
var health: Health
var alive: bool = true
var respawn_point: Vector3 = Vector3.ZERO
# F-mode: when set, WASD drives the commander directly instead of click-to-move.
var f_mode: bool = false
var _respawn_timer: float = 0.0
var _beam_accum: float = 0.0

func setup(p_shard: VoxelShard, p_team: int = 0) -> void:
	shard = p_shard
	rig = BlendShellRig.new()
	rig.height = 1.15
	rig.build = 1.2
	rig.head_scale = 1.0
	rig.team_index = p_team
	add_child(rig)
	anim = SillyPhysics.new()
	OutfitKit.apply(rig, "commander", "gold")

	# Collision capsule (single cheap collider — scales to many units later).
	var col := CollisionShape3D.new()
	var cap := CapsuleShape3D.new()
	cap.radius = 0.3
	cap.height = 1.1
	col.shape = cap
	col.position.y = 0.55
	add_child(col)
	# Terrain height is ground-truth from the heightmap (driven in _physics_process),
	# so the commander must NOT body-collide with chunk colliders or he gets stuck.
	# Units-on-unit separation comes from the spatial hash in Phase 3.
	collision_layer = 2
	collision_mask = 0

	beam_mesh = _make_beam()
	beam_mesh.visible = false
	add_child(beam_mesh)

	health = Health.new(300, 5)
	health.died.connect(_on_died)
	respawn_point = position

func _make_beam() -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	var m := CylinderMesh.new()
	m.top_radius = 0.06
	m.bottom_radius = 0.12
	m.height = 1.0
	mi.mesh = m
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.5, 0.9, 1.0, 0.6)
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.emission_enabled = true
	mat.emission = Color(0.5, 0.9, 1.0)
	mat.emission_energy_multiplier = 2.0
	mi.material_override = mat
	return mi

func order_move(pos: Vector3) -> void:
	target_position = pos
	has_target = true
	beaming = false
	beam_mesh.visible = false

func order_beam_gather(world_pos: Vector3) -> void:
	beam_target = world_pos
	beaming = true
	has_target = true
	target_position = world_pos

func _physics_process(delta: float) -> void:
	if not alive:
		# Down: count down to respawn at the Keep/respawn point.
		_respawn_timer -= delta
		if _respawn_timer <= 0.0:
			_respawn()
		return
	var ground_y: float = float(shard.get_height(int(floor(position.x)), int(floor(position.z))))
	var on_ground: bool = position.y <= ground_y + 0.05

	if not on_ground:
		velocity.y -= 20.0 * delta
	else:
		velocity.y = 0.0
		position.y = ground_y

	var horizontal := Vector3(velocity.x, 0.0, velocity.z)
	if f_mode:
		# Direct WASD drive in F-mode; click-to-move target is ignored.
		var input_dir := Vector2(
			Input.get_axis("cam_pan_left", "cam_pan_right"),
			Input.get_axis("cam_pan_up", "cam_pan_down"))
		if input_dir.length() > 0.01:
			input_dir = input_dir.normalized()
			var fwd: Vector3 = -global_transform.basis.z
			fwd.y = 0.0
			fwd = fwd.normalized()
			var right: Vector3 = global_transform.basis.x
			right.y = 0.0
			right = right.normalized()
			horizontal = (right * input_dir.x + fwd * -input_dir.y) * SPEED
			_face(horizontal)
		else:
			horizontal = Vector3.ZERO
	elif has_target:
		var to_target := Vector3(target_position.x, 0.0, target_position.z) - Vector3(position.x, 0.0, position.z)
		var dist: float = to_target.length()
		var stop_dist: float = BEAM_RANGE if beaming else 0.2
		if dist <= stop_dist:
			has_target = false
			horizontal = Vector3.ZERO
			if not beaming:
				arrived.emit()
		else:
			horizontal = to_target.normalized() * SPEED
			_face(to_target)

	velocity.x = horizontal.x
	velocity.z = horizontal.z
	move_and_slide()

	var moving_speed: float = Vector2(velocity.x, velocity.z).length() / SPEED
	if beaming and not has_target:
		_do_beam(delta)
		anim.mode = SillyPhysics.Mode.WORK
		_update_beam_visual()
	else:
		beam_mesh.visible = false
		anim.mode = SillyPhysics.Mode.RUN if moving_speed > 0.1 else SillyPhysics.Mode.IDLE

	anim.update(rig, delta, moving_speed)

func _face(dir: Vector3) -> void:
	if dir.length() > 0.01:
		var target_yaw: float = atan2(-dir.x, -dir.z)
		rotation.y = lerp_angle(rotation.y, target_yaw, 0.2)

func _do_beam(delta: float) -> void:
	_beam_accum += delta * BEAM_RATE
	if _beam_accum < 1.0:
		return
	_beam_accum -= 1.0
	if cargo >= CARGO_CAPACITY:
		beaming = false
		return
	# Mine the surface voxel at the beam target.
	var x: int = int(floor(beam_target.x))
	var z: int = int(floor(beam_target.z))
	var h: int = shard.get_height(x, z)
	if h > 0:
		shard.set_material(x, h - 1, z, 0)
		cargo += 1
		cargo_changed.emit(cargo, CARGO_CAPACITY)
		Events.add_resource(civ_id, &"stone", 1)  # provisional: mined material -> stone

func _update_beam_visual() -> void:
	beam_mesh.visible = true
	var from: Vector3 = rig.anchor_hand_right().global_position
	var local_from: Vector3 = to_local(from)
	var local_to: Vector3 = to_local(beam_target)
	var mid: Vector3 = (local_from + local_to) * 0.5
	var dir: Vector3 = local_to - local_from
	var beam_len: float = dir.length()
	beam_mesh.position = mid
	var scale_y: float = maxf(beam_len, 0.01)
	beam_mesh.scale = Vector3(1.0, scale_y, 1.0)
	if beam_len > 0.01:
		var up := Vector3.UP
		var axis: Vector3 = up.cross(dir.normalized())
		if axis.length() > 0.001:
			var angle: float = up.angle_to(dir.normalized())
			beam_mesh.rotation = Vector3.ZERO
			beam_mesh.rotate(axis.normalized(), angle)

func deposit_at_keep() -> int:
	# Returns cargo deposited; Keep accounting comes in Phase 4.
	var deposited: int = cargo
	cargo = 0
	cargo_changed.emit(cargo, CARGO_CAPACITY)
	return deposited

func _on_died() -> void:
	if not alive:
		return
	alive = false
	beaming = false
	has_target = false
	beam_mesh.visible = false
	_respawn_timer = RESPAWN_TIME
	anim.mode = SillyPhysics.Mode.TUMBLE
	if rig != null:
		rig.visible = false
	commander_died.emit()

func _respawn() -> void:
	alive = true
	health.heal(health.max_hp)
	position = respawn_point
	velocity = Vector3.ZERO
	if rig != null:
		rig.visible = true
	anim.mode = SillyPhysics.Mode.IDLE
	commander_respawned.emit()
