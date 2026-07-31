class_name Soldier
extends CharacterBody3D
## Military unit. Reuses the procedural blend-shell rig + silly-physics anim.
## Combat brain: guard a post, chase a target in range, attack with cooldown.
## Orders come through order_* methods (command boundary).

const SPEED: float = 3.0
const ATTACK_RANGE: float = 1.6
const AGGRO_RANGE: float = 9.0
const ATTACK_COOLDOWN: float = 0.9
const DAMAGE: int = 12

var civ_id: StringName = &"player"
var shard: VoxelShard
var rig: BlendShellRig
var anim: SillyPhysics
var health: Health

var move_target: Vector3 = Vector3.ZERO
var has_move_target: bool = false
var guard_post: Vector3 = Vector3.ZERO
var target: Node3D = null          # enemy unit to chase/attack
var _cooldown: float = 0.0

signal died_soldier(s: Soldier)

func setup(p_shard: VoxelShard, p_team: int = 0, tier: String = "stone") -> void:
	shard = p_shard
	rig = BlendShellRig.new()
	rig.height = 1.0
	rig.build = 1.0
	rig.team_index = p_team
	add_child(rig)
	anim = SillyPhysics.new()
	OutfitKit.apply(rig, "soldier", tier)
	OutfitKit.give_tool(rig, "spear", tier)
	health = Health.new(80, 2)
	health.died.connect(_on_died)
	guard_post = position

	var col := CollisionShape3D.new()
	var cap := CapsuleShape3D.new()
	cap.radius = 0.3
	cap.height = 1.0
	col.shape = cap
	col.position.y = 0.5
	add_child(col)
	collision_layer = 2
	collision_mask = 0

# --- Order API (command boundary) -------------------------------------------

func order_move(pos: Vector3) -> void:
	target = null
	move_to(pos)

func order_attack(unit: Node3D) -> void:
	target = unit

func order_guard(pos: Vector3) -> void:
	guard_post = pos
	target = null
	move_to(pos)

func order_attack_move(pos: Vector3) -> void:
	# Advance to a point; auto-acquire and fight enemies met along the way.
	guard_post = pos
	target = null
	move_to(pos)

func move_to(pos: Vector3) -> void:
	move_target = pos
	has_move_target = true

func _physics_process(delta: float) -> void:
	if not health.is_alive():
		return
	var ground_y: float = float(shard.get_height(int(floor(position.x)), int(floor(position.z))))
	position.y = ground_y
	_cooldown = maxf(_cooldown - delta, 0.0)

	# Acquire a target if we don't have one (nearest enemy in aggro range).
	if target == null or not is_instance_valid(target):
		target = _find_enemy()

	var moving: float = 0.0
	if target != null and is_instance_valid(target):
		moving = _combat_move(target, delta)
	else:
		# No enemy: hold at guard post.
		if has_move_target:
			moving = _step_toward(move_target, delta)
		elif position.distance_to(guard_post) > 1.0:
			move_to(guard_post)
			moving = _step_toward(guard_post, delta)

	_update_anim(moving)
	anim.update(rig, delta, moving)

func _combat_move(t: Node3D, delta: float) -> float:
	var d: float = position.distance_to(t.position)
	if d > ATTACK_RANGE:
		move_to(t.position)
		return _step_toward(t.position, delta)
	else:
		has_move_target = false
		_face(t.position - position)
		if _cooldown <= 0.0:
			_cooldown = ATTACK_COOLDOWN
			anim.mode = SillyPhysics.Mode.WORK  # attack swing
			_deal_damage(t)
		return 0.0

func _deal_damage(t: Node3D) -> void:
	# Enemy soldiers/peasants/commanders expose `health`.
	if t.get("health") is Health:
		(t.get("health") as Health).take_damage(DAMAGE)

func _find_enemy() -> Node3D:
	# Provided by CombatManager via group membership; here we scan the tree's
	# "combatants" group for the nearest hostile in aggro range.
	var best: Node3D = null
	var best_d: float = AGGRO_RANGE * AGGRO_RANGE
	for n in get_tree().get_nodes_in_group("combatants"):
		if n == self or not (n is Node3D):
			continue
		var nc: Variant = n.get("civ_id")
		if nc == null or StringName(nc) == civ_id:
			continue
		var nh: Variant = n.get("health")
		if nh is Health and not (nh as Health).is_alive():
			continue
		var d: float = position.distance_squared_to((n as Node3D).position)
		if d < best_d:
			best_d = d
			best = n
	return best

func _step_toward(dest: Vector3, _delta: float) -> float:
	var to := Vector3(dest.x, 0.0, dest.z) - Vector3(position.x, 0.0, position.z)
	if to.length() <= 0.25:
		has_move_target = false
		return 0.0
	_face(to)
	velocity.x = to.normalized().x * SPEED
	velocity.z = to.normalized().z * SPEED
	move_and_slide()
	return Vector2(velocity.x, velocity.z).length() / SPEED

func _face(dir: Vector3) -> void:
	if dir.length() > 0.01:
		rotation.y = lerp_angle(rotation.y, atan2(-dir.x, -dir.z), 0.3)

func _update_anim(moving: float) -> void:
	if target != null and is_instance_valid(target) and position.distance_to(target.position) <= ATTACK_RANGE:
		anim.mode = SillyPhysics.Mode.WORK
	elif moving > 0.1:
		anim.mode = SillyPhysics.Mode.RUN
	else:
		anim.mode = SillyPhysics.Mode.IDLE

func _on_died() -> void:
	died_soldier.emit(self)
	# Death anim: tumble then remove.
	anim.mode = SillyPhysics.Mode.TUMBLE
	set_physics_process(false)
	var tween := create_tween()
	tween.tween_interval(0.6)
	tween.tween_callback(queue_free)
