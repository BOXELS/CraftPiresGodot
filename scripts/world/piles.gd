class_name PileField
extends Node3D
## Ground piles of loose resources (food from kills, wood from felled trees).
## Peasants pick them up and haul them to storage. Rendered as small cubes.

const PILE_COLORS: Dictionary = {
	&"wood": Color(0.45, 0.32, 0.20),
	&"food": Color(0.85, 0.55, 0.30),
	&"stone": Color(0.55, 0.55, 0.58),
	&"dirt": Color(0.50, 0.38, 0.26),
}

var shard: VoxelShard
var piles: Array = []            # { "node": Node3D, "pos": Vector3, "kind": StringName, "amount": int }

func setup(p_shard: VoxelShard) -> void:
	shard = p_shard

## Drop a pile at a position; returns its index.
func drop(pos: Vector3, kind: StringName, amount: int) -> int:
	var node := Node3D.new()
	node.name = "pile_%s" % kind
	var gy: int = shard.get_height(int(pos.x), int(pos.z)) if shard != null else int(pos.y)
	var p := Vector3(pos.x, gy, pos.z)
	node.position = p
	var col: Color = PILE_COLORS.get(kind, Color(0.7, 0.7, 0.7))
	var mi := MeshInstance3D.new()
	var m := BoxMesh.new()
	m.size = Vector3(0.5, 0.3, 0.5)
	mi.mesh = m
	var mat := StandardMaterial3D.new()
	mat.albedo_color = col
	mat.roughness = 0.95
	mi.material_override = mat
	mi.position.y = 0.15
	node.add_child(mi)
	add_child(node)
	piles.append({"node": node, "pos": p, "kind": kind, "amount": amount})
	return piles.size() - 1

## Nearest pile within radius, or -1.
func nearest_pile(pos: Vector3, radius: float = 3.0) -> int:
	var best: int = -1
	var best_d: float = radius * radius
	for i in piles.size():
		var pl: Dictionary = piles[i]
		if int(pl["amount"]) <= 0:
			continue
		var d: float = Vector2(pl["pos"].x, pl["pos"].z).distance_squared_to(Vector2(pos.x, pos.z))
		if d < best_d:
			best_d = d
			best = i
	return best

## Take up to `want` from a pile; returns the amount actually taken.
func take(index: int, want: int) -> int:
	if index < 0 or index >= piles.size():
		return 0
	var pl: Dictionary = piles[index]
	var got: int = mini(int(pl["amount"]), want)
	pl["amount"] = int(pl["amount"]) - got
	if int(pl["amount"]) <= 0 and is_instance_valid(pl["node"]):
		pl["node"].queue_free()
	return got

func pile_kind(index: int) -> StringName:
	if index >= 0 and index < piles.size():
		return piles[index]["kind"]
	return &""

func pile_pos(index: int) -> Vector3:
	if index >= 0 and index < piles.size():
		return piles[index]["pos"]
	return Vector3.ZERO

func pile_amount(index: int) -> int:
	if index >= 0 and index < piles.size():
		return int(piles[index]["amount"])
	return 0

func pile_count() -> int:
	var n: int = 0
	for pl in piles:
		if int(pl["amount"]) > 0:
			n += 1
	return n
