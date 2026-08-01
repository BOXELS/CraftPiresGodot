class_name Peasant
extends CharacterBody3D
## AoE II-style worker. Driven by the task state machine in TaskBrain; this node
## is the body — movement on the heightmap, carry state, rig + animation.
## Orders come through order_* methods (the command boundary).

const SPEED: float = 2.6          # base; actual speed comes from stage
const CARRY_CAPACITY: int = 10    # stage 0 (primitive); rises with PeasantStage

var civ_id: StringName = &"player"
var shard: VoxelShard
var world: WorldBuilder            # for dig orders (terrain editing)
var rig: BlendShellRig
var anim: SillyPhysics
var brain: TaskBrain

var stage: int = PeasantStage.Stage.PRIMITIVE
var tool: StringName = &""        # &"axe" | &"pick" | &"hammer" | &"shovel"

var carrying: int = 0
var carry_kind: StringName = &""
var move_target: Vector3 = Vector3.ZERO
var has_move_target: bool = false

signal arrived
signal stage_changed(new_stage: int)

func setup(p_shard: VoxelShard, p_team: int = 0) -> void:
	shard = p_shard
	rig = BlendShellRig.new()
	rig.height = 0.9
	rig.build = 0.9
	rig.team_index = p_team
	add_child(rig)
	anim = SillyPhysics.new()
	OutfitKit.apply(rig, "peasant", "wood")
	brain = TaskBrain.new(self)

	var col := CollisionShape3D.new()
	var cap := CapsuleShape3D.new()
	cap.radius = 0.28
	cap.height = 0.9
	col.shape = cap
	col.position.y = 0.45
	add_child(col)
	collision_layer = 2
	collision_mask = 0  # heightmap is ground-truth; unit separation via spatial hash

# --- Order API (command boundary) -------------------------------------------

func order_move(pos: Vector3) -> void:
	brain.set_order(&"move", {"pos": pos})

func order_gather(node_pos: Vector3, kind: StringName = &"wood") -> void:
	brain.set_order(&"gather", {"pos": node_pos, "kind": kind})

func order_dig(pos: Vector3, kind: StringName = &"dirt") -> void:
	# Dig dirt / mine stone / harvest from the terrain itself.
	brain.set_order(&"dig", {"pos": pos, "kind": kind})

func order_haul(site: ConstructionSite, depot: StorageDepot) -> void:
	brain.set_order(&"haul", {"site": site, "depot": depot})

func order_build(site: ConstructionSite) -> void:
	brain.set_order(&"build", {"site": site})

func order_idle() -> void:
	brain.set_order(&"idle", {})

func order_hunt(animals: AnimalField, index: int) -> void:
	# Chase and kill wildlife for food.
	brain.set_order(&"hunt", {"animals": animals, "index": index, "pos": animals.animal_pos(index)})

func order_pick_pile(piles: PileField, index: int) -> void:
	# Collect a ground pile and haul it to storage.
	brain.set_order(&"pickpile", {"piles": piles, "index": index, "pos": piles.pile_pos(index), "kind": piles.pile_kind(index)})

# --- Stage / tools (Phase 5) -------------------------------------------------

func set_stage(new_stage: int) -> void:
	stage = clampi(new_stage, PeasantStage.Stage.PRIMITIVE, PeasantStage.Stage.ADVANCED)
	OutfitKit.apply(rig, "peasant", PeasantStage.outfit(stage))
	if tool != &"":
		equip_tool(tool)  # re-attach tool onto the fresh outfit
	stage_changed.emit(stage)

func work_speed() -> float:
	# Stage work multiplier × tool bonus (right tool for the job).
	var m: float = PeasantStage.work(stage)
	if tool != &"":
		m *= Tools.effect_multiplier(tool, _current_task_kind())
	return m

func _current_task_kind() -> StringName:
	if brain.order == &"dig":
		return brain.order_data.get("kind", &"dirt")
	if brain.order == &"gather":
		return &"wood"
	return &""

func equip_tool(t: StringName) -> void:
	tool = t
	if t != &"":
		OutfitKit.give_tool(rig, str(t).trim_suffix("_t1"), PeasantStage.outfit(stage))

func carry_capacity() -> int:
	return PeasantStage.carry(stage)

func move_speed() -> float:
	return PeasantStage.speed(stage)

func move_to(pos: Vector3) -> void:
	# Low-level locomotion used by the brain; not an order itself.
	move_target = pos
	has_move_target = true

func _physics_process(delta: float) -> void:
	var ground_y: float = float(shard.get_height(int(floor(position.x)), int(floor(position.z))))
	position.y = ground_y

	var horizontal := Vector3.ZERO
	if has_move_target:
		var to := Vector3(move_target.x, 0.0, move_target.z) - Vector3(position.x, 0.0, position.z)
		if to.length() <= 0.25:
			has_move_target = false
			arrived.emit()
		else:
			horizontal = to.normalized() * move_speed()
			_face(to)
	velocity.x = horizontal.x
	velocity.z = horizontal.z
	move_and_slide()

	var moving: float = Vector2(velocity.x, velocity.z).length() / move_speed()
	_update_anim(moving)
	anim.update(rig, delta, moving)

func _update_anim(moving: float) -> void:
	if brain.state == &"gathering" or brain.state == &"building" or brain.state == &"digging":
		anim.mode = SillyPhysics.Mode.WORK
	elif carrying > 0 and moving > 0.1:
		anim.mode = SillyPhysics.Mode.CARRY
	elif moving > 0.1:
		anim.mode = SillyPhysics.Mode.RUN
	else:
		anim.mode = SillyPhysics.Mode.IDLE

func _face(dir: Vector3) -> void:
	if dir.length() > 0.01:
		rotation.y = lerp_angle(rotation.y, atan2(-dir.x, -dir.z), 0.25)

func pick_up(kind: StringName, amount: int) -> void:
	carry_kind = kind
	carrying = mini(carrying + amount, carry_capacity())

func drop_off() -> int:
	var n: int = carrying
	carrying = 0
	carry_kind = &""
	return n
