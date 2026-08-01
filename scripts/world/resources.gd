class_name ResourceNodes
extends Node3D
## Block trees and boulders placed on the terrain. Trees fell into tumbling
## fragments (Jolt rigid bodies) that settle into log piles. Zero art: cubes.

const TREE_BLOCK: float = 0.5

var shard: VoxelShard
var _trees: Array = []

func setup(p_shard: VoxelShard) -> void:
	shard = p_shard

func scatter(rng: RandomNumberGenerator, count: int) -> void:
	for i in count:
		var x: int = rng.randi_range(4, VoxelShard.SIZE_X - 5)
		var z: int = rng.randi_range(4, VoxelShard.SIZE_Z - 5)
		var h: int = shard.get_height(x, z)
		if h <= 0 or shard.surface_material(x, z) != 1:
			continue  # trees only on grass
		_spawn_tree(Vector3(x + 0.5, h, z + 0.5), rng)

func _spawn_tree(base: Vector3, rng: RandomNumberGenerator) -> void:
	var tree := Node3D.new()
	tree.name = "tree"
	tree.position = base
	var trunk_h: int = rng.randi_range(2, 4)
	var mat_trunk := _mat(Color(0.45, 0.32, 0.20))
	var mat_leaf := _mat(Color(0.30, 0.55, 0.28))
	for i in trunk_h:
		tree.add_child(_block(Vector3(0, i * TREE_BLOCK + TREE_BLOCK * 0.5, 0), mat_trunk, Vector3.ONE * TREE_BLOCK))
	# Leaf canopy on top.
	for lx in [-0.5, 0.5]:
		for lz in [-0.5, 0.5]:
			tree.add_child(_block(Vector3(lx * TREE_BLOCK, trunk_h * TREE_BLOCK + TREE_BLOCK * 0.5, lz * TREE_BLOCK), mat_leaf, Vector3.ONE * TREE_BLOCK))
	tree.add_child(_block(Vector3(0, (trunk_h + 1) * TREE_BLOCK + TREE_BLOCK * 0.2, 0), mat_leaf, Vector3.ONE * TREE_BLOCK))
	add_child(tree)
	_trees.append(tree)

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

func tree_count() -> int:
	return _trees.size()

## Nearest living tree within `radius` of a point, or null. Used by context
## commands (RMB on a tree = gather wood).
func nearest_tree(pos: Vector3, radius: float = 2.0) -> Node3D:
	var best: Node3D = null
	var best_d: float = radius * radius
	for t in _trees:
		if not is_instance_valid(t):
			continue
		var d: float = Vector2(t.position.x, t.position.z).distance_squared_to(Vector2(pos.x, pos.z))
		if d < best_d:
			best_d = d
			best = t
	return best
