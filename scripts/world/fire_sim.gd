class_name FireSim
extends RefCounted
## Cellular fire spread on the voxel grid (Phase 9). Burning cells ignite
## flammable lateral neighbors on a fixed tick (seeded rng for determinism);
## water extinguishes. State is a per-column burn flag + burn time.

const SIZE_X: int = VoxelShard.SIZE_X
const SIZE_Z: int = VoxelShard.SIZE_Z
const BURN_TIME: int = 6          # ticks a cell stays alight before burning out

var shard: VoxelShard
var water: WaterSim
var rng: RandomNumberGenerator
var _burning: Dictionary = {}     # index -> ticks remaining

func _init(p_shard: VoxelShard, p_water: WaterSim, seed_value: int) -> void:
	shard = p_shard
	water = p_water
	rng = RandomNumberGenerator.new()
	rng.seed = seed_value

static func index(x: int, z: int) -> int:
	return z * SIZE_X + x

func ignite(x: int, z: int) -> bool:
	if x < 0 or x >= SIZE_X or z < 0 or z >= SIZE_Z:
		return false
	var h: int = shard.get_height(x, z)
	if h <= 0:
		return false
	if MaterialInteractions.extinguished(water.level(x, z)):
		return false
	if not MaterialInteractions.is_flammable(shard.surface_material(x, z)):
		return false
	_burning[index(x, z)] = BURN_TIME
	return true

func is_burning(x: int, z: int) -> bool:
	return _burning.has(index(x, z))

func burning_count() -> int:
	return _burning.size()

## One spread tick. Burning cells try to ignite neighbors; burn time decrements;
## burned-out cells are consumed (surface turns to dirt/ash).
func step() -> int:
	var new_fires: Array = []
	var to_remove: Array = []
	for i in _burning.keys():
		var x: int = i % SIZE_X
		var z: int = i / SIZE_X
		# Water puts it out.
		if MaterialInteractions.extinguished(water.level(x, z)):
			to_remove.append(i)
			continue
		# Spread to flammable neighbors.
		for d in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
			var nx: int = x + d.x
			var nz: int = z + d.y
			if nx < 0 or nx >= SIZE_X or nz < 0 or nz >= SIZE_Z:
				continue
			if _burning.has(index(nx, nz)):
				continue
			var nmat: int = shard.surface_material(nx, nz)
			if MaterialInteractions.fire_spreads(rng, nmat) and not MaterialInteractions.extinguished(water.level(nx, nz)):
				new_fires.append(index(nx, nz))
		# Decrement burn.
		_burning[i] = int(_burning[i]) - 1
		if int(_burning[i]) <= 0:
			to_remove.append(i)
			# Consume the surface: grass -> dirt.
			var h: int = shard.get_height(x, z)
			if h > 0 and shard.get_material(x, h - 1, z) == 1:
				shard.set_material(x, h - 1, z, 2)
	for i in to_remove:
		_burning.erase(i)
	var added: int = 0
	for i in new_fires:
		if not _burning.has(i):
			_burning[i] = BURN_TIME
			added += 1
	return added
