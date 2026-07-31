class_name ConstructionSite
extends Node3D
## A placed foundation. Tracks the bill of materials, materials delivered by
## hauling peasants, and build progress across 4 phases (foundation/walls/roof/
## details). Renders a scaffold that rises with progress. No prefab — voxels.

signal materials_fulfilled
signal completed(building_kind: StringName)

enum Phase { FOUNDATION, WALLS, ROOF, DETAILS, DONE }

var kind: StringName = &"house"
var civ_id: StringName = &"player"
var bom: Dictionary = {}
var delivered: Dictionary = {}       # kind -> amount delivered
var phase: Phase = Phase.FOUNDATION
var progress: float = 0.0            # 0..1 within current phase set
var build_rate: float = 10.0         # voxels/sec baseline, scaled by workers
var workers: Array = []

var _scaffold: Node3D
var _base_y: int = 0
var _fp: Vector2i = Vector2i(2, 2)

func setup(p_kind: StringName, p_civ: StringName, ground_y: int) -> void:
	kind = p_kind
	civ_id = p_civ
	bom = BuildingDefs.bom(kind).duplicate(true)
	_fp = BuildingDefs.footprint(kind)
	_base_y = ground_y
	for k in bom:
		delivered[k] = 0
	_build_scaffold()
	_update_visual()

func total_bom_voxels() -> int:
	var t: int = 0
	for k in bom:
		t += int(bom[k])
	return t

func total_delivered() -> int:
	var t: int = 0
	for k in delivered:
		t += int(delivered[k])
	return t

func needed_material() -> StringName:
	# Returns the next material kind still needed, or &"" when fully stocked.
	for k in bom:
		if int(delivered[k]) < int(bom[k]):
			return k
	return &""

func is_fully_stocked() -> bool:
	return needed_material() == &""

func deliver(mat: StringName, amount: int) -> int:
	# Accepts up to what's still needed; returns amount actually accepted.
	if not delivered.has(mat):
		return 0
	var still_needed: int = int(bom[mat]) - int(delivered[mat])
	var accepted: int = mini(amount, still_needed)
	delivered[mat] = int(delivered[mat]) + accepted
	if is_fully_stocked():
		materials_fulfilled.emit()
	return accepted

func add_worker(w: Node) -> void:
	if not workers.has(w):
		workers.append(w)

func remove_worker(w: Node) -> void:
	workers.erase(w)

func worker_speed_multiplier() -> float:
	# Diminishing returns per design doc.
	match workers.size():
		0, 1: return 1.0
		2: return 1.8
		3, 4: return 2.5
		5, 6, 7, 8: return 3.5
		_: return 4.0

func build_tick(delta: float) -> void:
	if phase == Phase.DONE or not is_fully_stocked():
		return
	if workers.is_empty():
		return
	var total: float = float(total_bom_voxels())
	var per_phase_voxels: float = total / 4.0
	var rate: float = build_rate * worker_speed_multiplier()
	progress += (rate * delta) / per_phase_voxels
	if progress >= 1.0:
		progress = 0.0
		_advance_phase()
	_update_visual()

func _advance_phase() -> void:
	match phase:
		Phase.FOUNDATION: phase = Phase.WALLS
		Phase.WALLS: phase = Phase.ROOF
		Phase.ROOF: phase = Phase.DETAILS
		Phase.DETAILS:
			phase = Phase.DONE
			completed.emit(kind)

func progress_fraction() -> float:
	# Overall 0..1 across all phases for UI.
	var phase_base: float = float(int(phase)) / 5.0
	return clampf(phase_base + progress / 5.0, 0.0, 1.0)

func _build_scaffold() -> void:
	_scaffold = Node3D.new()
	_scaffold.name = "Scaffold"
	add_child(_scaffold)

func _update_visual() -> void:
	if _scaffold == null:
		return
	for c in _scaffold.get_children():
		c.queue_free()
	var color := BuildingDefs.color(kind)
	var mat := _mat(color)
	# Foundation pad always shows once placed.
	var height_blocks: int = 1 + int(phase)  # rises per phase
	if phase == Phase.DONE:
		height_blocks = 4
	for bx in _fp.x:
		for bz in _fp.y:
			for by in height_blocks:
				var b := MeshInstance3D.new()
				var m := BoxMesh.new()
				m.size = Vector3(0.98, 0.98, 0.98)
				b.mesh = m
				b.material_override = mat
				b.position = Vector3(bx + 0.5, by + 0.5, bz + 0.5)
				_scaffold.add_child(b)

func _mat(color: Color) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_color = color
	m.roughness = 0.85
	return m
