class_name AnimalField
extends Node3D
## Wandering wildlife that peasants hunt for food. Blocky critters (zero art)
## that amble on the heightmap. Killing one drops a food pile to haul.

const ANIMAL_BLOCK: float = 0.4

var shard: VoxelShard
var animals: Array = []          # { "node": Node3D, "pos": Vector3, "hp": int, "alive": bool, "wander": float, "dir": Vector2 }

signal animal_killed(pos: Vector3, food: int)

func setup(p_shard: VoxelShard) -> void:
	shard = p_shard

func scatter(rng: RandomNumberGenerator, count: int) -> void:
	for i in count:
		var x: int = rng.randi_range(6, VoxelShard.SIZE_X - 7)
		var z: int = rng.randi_range(6, VoxelShard.SIZE_Z - 7)
		var h: int = shard.get_height(x, z)
		if h <= 0 or shard.surface_material(x, z) != 1:
			continue  # graze on grass
		_spawn(Vector3(x + 0.5, h, z + 0.5), rng)

func _spawn(base: Vector3, rng: RandomNumberGenerator) -> void:
	var body := Node3D.new()
	body.name = "animal"
	body.position = base
	var hide := _mat(Color(0.72, 0.60, 0.45))
	var dark := _mat(Color(0.45, 0.35, 0.25))
	# Body + head + legs — a low-poly grazer.
	body.add_child(_block(Vector3(0, 0.45, 0), hide, Vector3(0.9, 0.5, 0.5)))
	body.add_child(_block(Vector3(0.55, 0.6, 0), dark, Vector3(0.35, 0.35, 0.35)))
	for lx in [-0.3, 0.3]:
		for lz in [-0.15, 0.15]:
			body.add_child(_block(Vector3(lx, 0.1, lz), dark, Vector3(0.12, 0.3, 0.12)))
	add_child(body)
	animals.append({
		"node": body, "pos": base, "hp": 2, "alive": true,
		"wander": rng.randf_range(1.0, 3.0),
		"dir": Vector2.RIGHT.rotated(rng.randf() * TAU),
	})

func _block(pos: Vector3, mat: Material, size: Vector3) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	var m := BoxMesh.new()
	m.size = size
	mi.mesh = m
	mi.material_override = mat
	mi.position = pos
	return mi

func _mat(color: Color) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_color = color
	m.roughness = 0.9
	return m

func _process(delta: float) -> void:
	if not Sim.running:
		return
	for a in animals:
		if not a["alive"] or not is_instance_valid(a["node"]):
			continue
		a["wander"] = float(a["wander"]) - delta
		if float(a["wander"]) <= 0.0:
			a["wander"] = Sim.rng.randf_range(1.5, 4.0)
			a["dir"] = Vector2.RIGHT.rotated(Sim.rng.randf() * TAU)
		var dir: Vector2 = a["dir"]
		var pos: Vector3 = a["pos"]
		var nx: float = pos.x + dir.x * delta * 0.8
		var nz: float = pos.z + dir.y * delta * 0.8
		# Stay on walkable grass; bounce off edges / water.
		if nx < 2 or nx >= VoxelShard.SIZE_X - 2 or nz < 2 or nz >= VoxelShard.SIZE_Z - 2:
			a["dir"] = -dir
			continue
		var h: int = shard.get_height(int(nx), int(nz))
		if h <= 0:
			a["dir"] = -dir
			continue
		pos.x = nx
		pos.z = nz
		pos.y = h
		a["pos"] = pos
		a["node"].position = pos
		a["node"].rotation.y = -dir.angle()

## Nearest living animal within radius of a point (context command target).
func nearest_animal(pos: Vector3, radius: float = 3.0) -> int:
	var best: int = -1
	var best_d: float = radius * radius
	for i in animals.size():
		var a: Dictionary = animals[i]
		if not a["alive"]:
			continue
		var d: float = Vector2(a["pos"].x, a["pos"].z).distance_squared_to(Vector2(pos.x, pos.z))
		if d < best_d:
			best_d = d
			best = i
	return best

## Damage an animal; returns food dropped (0 if still alive).
func damage(index: int, amount: int = 1) -> int:
	if index < 0 or index >= animals.size():
		return 0
	var a: Dictionary = animals[index]
	if not a["alive"]:
		return 0
	a["hp"] = int(a["hp"]) - amount
	if int(a["hp"]) > 0:
		return 0
	a["alive"] = false
	if is_instance_valid(a["node"]):
		a["node"].queue_free()
	var food: int = 20
	animal_killed.emit(a["pos"], food)
	return food

func animal_pos(index: int) -> Vector3:
	if index >= 0 and index < animals.size():
		return animals[index]["pos"]
	return Vector3.ZERO

func is_alive(index: int) -> bool:
	return index >= 0 and index < animals.size() and animals[index]["alive"]

func alive_count() -> int:
	var n: int = 0
	for a in animals:
		if a["alive"]:
			n += 1
	return n
