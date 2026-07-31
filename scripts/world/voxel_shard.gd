class_name VoxelShard
extends RefCounted
## Column-based voxel storage for one shard. 128x128 columns, up to 64 high.
## Data is flat PackedByteArray per column (material IDs, 0 = air) so it stays
## compact and serialization-friendly. Rendering reads a surface heightmap +
## material map; underground exists in data but is meshed only when exposed.

const SIZE_X: int = 128
const SIZE_Z: int = 128
const MAX_Y: int = 64

# Terrain regions: broad flat plains broken by grouped hill clusters and a
# mountain band. Thresholds on the region mask (below).
const PLAINS_HEIGHT: float = 9.0    # gentle base elevation of flat land
const HILLS_HEIGHT: float = 22.0
const MOUNTAIN_HEIGHT: float = 46.0

# columns[x][z] -> PackedByteArray of MAX_Y material IDs (bottom to top)
var _columns: Array = []
var heights: PackedInt32Array = PackedInt32Array()

func _init() -> void:
	_columns.resize(SIZE_X * SIZE_Z)
	heights.resize(SIZE_X * SIZE_Z)

static func index(x: int, z: int) -> int:
	return z * SIZE_X + x

func generate(new_seed: int) -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = new_seed
	var region := FastNoiseLite.new()
	region.seed = new_seed
	region.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
	region.frequency = 0.012
	region.fractal_octaves = 2

	# Detail noise for hills & mountains (rugged).
	var rugged := FastNoiseLite.new()
	rugged.seed = new_seed + 101
	rugged.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
	rugged.frequency = 0.06
	rugged.fractal_octaves = 5

	# Gentle undulation for plains so flats aren't perfectly uniform.
	var gentle := FastNoiseLite.new()
	gentle.seed = new_seed + 202
	gentle.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
	gentle.frequency = 0.03
	gentle.fractal_octaves = 2

	for x in SIZE_X:
		for z in SIZE_Z:
			var col := PackedByteArray()
			col.resize(MAX_Y)
			col.fill(0)

			var r: float = region.get_noise_2d(float(x), float(z)) * 0.5 + 0.5  # 0..1
			var rough: float = rugged.get_noise_2d(float(x), float(z)) * 0.5 + 0.5
			var soft: float = gentle.get_noise_2d(float(x), float(z)) * 0.5 + 0.5

			# Blend flat plains -> rolling hills -> mountains with wide, soft
			# transition bands so edges aren't hard cliff lines. Plains keep a
			# gentle undulation; hills add mid relief; mountains stack on top.
			var hill_amt: float = smoothstep(0.40, 0.62, r)        # wide band into hills
			var mount_amt: float = smoothstep(0.68, 0.88, r)       # wide band into peaks
			var plains_h: float = PLAINS_HEIGHT + soft * 4.0       # ~9..13, soft flats
			var hills_h: float = HILLS_HEIGHT + (rough - 0.5) * 10.0  # rolling 17..27
			var mount_h: float = MOUNTAIN_HEIGHT + rough * 16.0    # tall peaks

			var h_f: float = lerpf(plains_h, hills_h, hill_amt)
			h_f = lerpf(h_f, mount_h, mount_amt)
			var h: int = clampi(int(h_f), 6, MAX_Y - 2)

			for y in h:
				col[y] = _material_for_depth(y, h, rng)
			_columns[index(x, z)] = col
			heights[index(x, z)] = h

func _material_for_depth(y: int, h: int, rng: RandomNumberGenerator) -> int:
	# Material IDs: 1 grass, 2 dirt, 3 stone, 4 sand, 5 snow. Surface mostly
	# grass; high peaks turn to stone/snow. Subsoil dirt, stone below.
	if y == h - 1:
		if h >= 40:
			return 5  # snow-capped peaks
		elif h >= 30:
			return 3  # bare stone on high ground
		return 4 if rng.randf() < 0.04 else 1
	elif y >= h - 3:
		return 2
	else:
		return 3

func get_material(x: int, y: int, z: int) -> int:
	if x < 0 or x >= SIZE_X or z < 0 or z >= SIZE_Z or y < 0 or y >= MAX_Y:
		return 0
	return _columns[index(x, z)][y]

## Restore from a saved game: overwrite columns + heights directly (Phase 6).
func restore(heights_arr: Array, columns_arr: Array) -> void:
	for i in mini(heights_arr.size(), SIZE_X * SIZE_Z):
		heights[i] = int(heights_arr[i])
	for i in mini(columns_arr.size(), SIZE_X * SIZE_Z):
		var col := PackedByteArray()
		col.resize(MAX_Y)
		var src: Array = columns_arr[i]
		for y in mini(src.size(), MAX_Y):
			col[y] = int(src[y])
		_columns[i] = col

func get_height(x: int, z: int) -> int:
	if x < 0 or x >= SIZE_X or z < 0 or z >= SIZE_Z:
		return 0
	return heights[index(x, z)]

func set_material(x: int, y: int, z: int, material: int) -> void:
	if x < 0 or x >= SIZE_X or z < 0 or z >= SIZE_Z or y < 0 or y >= MAX_Y:
		return
	_columns[index(x, z)][y] = material
	if material == 0:
		# Removing: height may have dropped.
		if y == heights[index(x, z)] - 1:
			heights[index(x, z)] = _recalc_height(x, z)
	else:
		# Adding: height rises if we placed above the current top.
		if y + 1 > heights[index(x, z)]:
			heights[index(x, z)] = y + 1

func _recalc_height(x: int, z: int) -> int:
	var col: PackedByteArray = _columns[index(x, z)]
	for y in range(MAX_Y - 1, -1, -1):
		if col[y] != 0:
			return y + 1
	return 0

## Surface material at the top of a column (what the mesher draws for the top face).
func surface_material(x: int, z: int) -> int:
	var h: int = get_height(x, z)
	if h <= 0:
		return 0
	return get_material(x, h - 1, z)
