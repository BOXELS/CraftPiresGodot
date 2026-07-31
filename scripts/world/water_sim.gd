class_name WaterSim
extends RefCounted
## Deterministic cellular water on the voxel grid (Phase 9). Each water cell
## holds a level 0..7; water flows to lower/level neighbors on a fixed tick,
## chunk-local and budgeted per step. State lives in the grid — multiplayer-safe.
## Water sits in a separate overlay (not a terrain material) so it can rest on
## top of ground columns and reroute through dug channels.

const MAX_LEVEL: int = 7
const SIZE_X: int = VoxelShard.SIZE_X
const SIZE_Z: int = VoxelShard.SIZE_Z

var shard: VoxelShard
var _level: PackedByteArray = PackedByteArray()   # per-column water level 0..7

func _init(p_shard: VoxelShard) -> void:
	shard = p_shard
	_level.resize(SIZE_X * SIZE_Z)
	_level.fill(0)

static func index(x: int, z: int) -> int:
	return z * SIZE_X + x

func level(x: int, z: int) -> int:
	if x < 0 or x >= SIZE_X or z < 0 or z >= SIZE_Z:
		return 0
	return _level[index(x, z)]

func set_water(x: int, z: int, lvl: int) -> void:
	if x < 0 or x >= SIZE_X or z < 0 or z >= SIZE_Z:
		return
	_level[index(x, z)] = clampi(lvl, 0, MAX_LEVEL)

func add_water(x: int, z: int, amount: int) -> void:
	set_water(x, z, level(x, z) + amount)

func is_water(x: int, z: int) -> bool:
	return level(x, z) > 0

func water_surface_y(x: int, z: int) -> int:
	# Top of the water column = ground height + water depth (1 block per level
	# is too deep; treat level as a fraction filling one block).
	return shard.get_height(x, z)

## One deterministic flow step over a window of columns. Water moves from a
## cell to a lower ground neighbor if it can pool there; level equalizes across
## flat ground. `budget` caps cells processed per step (perf).
func step(cx0: int, cz0: int, cx1: int, cz1: int, budget: int = 4096) -> int:
	var moved: int = 0
	var deltas: Dictionary = {}  # index -> net level change this step
	for x in range(cx0, cx1):
		for z in range(cz0, cz1):
			if moved >= budget:
				return moved
			var lvl: int = level(x, z)
			if lvl <= 0:
				continue
			var h_here: int = shard.get_height(x, z)
			# Try to flow to the lowest neighbor.
			var best: Vector2i = Vector2i(-1, -1)
			var best_h: int = h_here
			for d in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
				var nx: int = x + d.x
				var nz: int = z + d.y
				if nx < 0 or nx >= SIZE_X or nz < 0 or nz >= SIZE_Z:
					continue
				var nh: int = shard.get_height(nx, nz)
				if nh < best_h:
					best_h = nh
					best = Vector2i(nx, nz)
			if best.x >= 0 and best_h < h_here:
				# Flow downhill: move one level to the lower neighbor.
				var from_i: int = index(x, z)
				var to_i: int = index(best.x, best.y)
				deltas[from_i] = int(deltas.get(from_i, 0)) - 1
				deltas[to_i] = int(deltas.get(to_i, 0)) + 1
				moved += 1
			else:
				# Flat: equalize with lower-level lateral neighbors.
				for d in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
					var nx2: int = x + d.x
					var nz2: int = z + d.y
					if nx2 < 0 or nx2 >= SIZE_X or nz2 < 0 or nz2 >= SIZE_Z:
						continue
					if shard.get_height(nx2, nz2) != h_here:
						continue
					if level(nx2, nz2) + 1 < lvl:
						var fi: int = index(x, z)
						var ti: int = index(nx2, nz2)
						deltas[fi] = int(deltas.get(fi, 0)) - 1
						deltas[ti] = int(deltas.get(ti, 0)) + 1
						moved += 1
						break
	# Apply net changes.
	for i in deltas:
		var x: int = i % SIZE_X
		var z: int = int(i / float(SIZE_X))
		set_water(x, z, level(x, z) + int(deltas[i]))
	return moved

## Drain water at a cell (e.g. bank cut / bucket). Returns amount removed.
func drain(x: int, z: int, amount: int = 1) -> int:
	var take: int = mini(amount, level(x, z))
	set_water(x, z, level(x, z) - take)
	return take
