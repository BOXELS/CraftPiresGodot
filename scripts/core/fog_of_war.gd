class_name FogOfWar
extends RefCounted
## Per-civ fog of war over the shard grid. Units and buildings reveal tiles in a
## radius; tiles are UNEXPLORED -> EXPLORED (seen once, dim) -> VISIBLE (now).
## Rendered as a dark overlay; gameplay queries use is_visible for targeting.

enum Vis { UNEXPLORED, EXPLORED, VISIBLE }

const SIZE_X: int = VoxelShard.SIZE_X
const SIZE_Z: int = VoxelShard.SIZE_Z

var civ_id: StringName = &"player"
var _vis: PackedByteArray = PackedByteArray()   # one byte per tile

func _init(p_civ: StringName = &"player") -> void:
	civ_id = p_civ
	_vis.resize(SIZE_X * SIZE_Z)
	_vis.fill(Vis.UNEXPLORED)

static func index(x: int, z: int) -> int:
	return z * SIZE_X + x

func reveal(cx: int, cz: int, radius: int) -> void:
	# Mark a disc visible; previously-unexplored tiles become explored too.
	for dx in range(-radius, radius + 1):
		for dz in range(-radius, radius + 1):
			if dx * dx + dz * dz > radius * radius:
				continue
			var x: int = cx + dx
			var z: int = cz + dz
			if x < 0 or x >= SIZE_X or z < 0 or z >= SIZE_Z:
				continue
			_vis[index(x, z)] = Vis.VISIBLE

func refresh_visibility(sources: Array) -> void:
	# Each tick: demote all VISIBLE to EXPLORED, then re-reveal from sources.
	# sources: Array of {x, z, radius}.
	for i in _vis.size():
		if _vis[i] == Vis.VISIBLE:
			_vis[i] = Vis.EXPLORED
	for s in sources:
		reveal(int(s.get("x", 0)), int(s.get("z", 0)), int(s.get("radius", 6)))

func is_visible(x: int, z: int) -> bool:
	if x < 0 or x >= SIZE_X or z < 0 or z >= SIZE_Z:
		return false
	return _vis[index(x, z)] == Vis.VISIBLE

func is_explored(x: int, z: int) -> bool:
	if x < 0 or x >= SIZE_X or z < 0 or z >= SIZE_Z:
		return false
	return _vis[index(x, z)] >= Vis.EXPLORED

func visible_count() -> int:
	var n: int = 0
	for i in _vis.size():
		if _vis[i] == Vis.VISIBLE:
			n += 1
	return n

func explored_count() -> int:
	var n: int = 0
	for i in _vis.size():
		if _vis[i] >= Vis.EXPLORED:
			n += 1
	return n
