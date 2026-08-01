class_name MaterialInteractions
extends RefCounted
## Material combination rules (Phase 9). Water + dirt -> mud (slows units);
## fire spreads to flammable neighbors; water extinguishes fire. Dirt roads
## give a Settlers-style move bonus. All queries are pure lookups so outcomes
## stay deterministic.

const MUD_SLOW: float = 0.55       # movement multiplier on mud
const ROAD_SPEED: float = 1.35     # dirt road bonus (MVP parity)
const ROAD_DIRT: int = 6           # VoxelShard surface id for paved path
const DIRT_ROAD_COST: int = 2      # dirt stock per paved tile
const FIRE_SPREAD_CHANCE: float = 0.3

# Material ids (match VoxelShard): 1 grass, 2 dirt, 3 stone, 4 sand, 5 snow, 6 road.
# Fire/mud are transient states tracked on the grid via meta maps.

static func is_flammable(mat: int) -> bool:
	return mat == 1 or mat == 2  # grass, dirt (trees handled by resources)

static func can_pave_dirt_road(mat: int) -> bool:
	# Roads replace grass/dirt; already-paved and rock/sand/snow are rejected.
	return mat == 1 or mat == 2

## Mud: a column with water on dirt/grass becomes mud — slows ground movement.
## Dirt roads give +35% move speed when dry.
static func move_multiplier(water_lvl: int, ground_mat: int) -> float:
	if water_lvl > 0 and (ground_mat == 1 or ground_mat == 2 or ground_mat == ROAD_DIRT):
		return MUD_SLOW
	if water_lvl > MAX_SHALLOW:
		return 0.4  # wading through deeper water
	if ground_mat == ROAD_DIRT:
		return ROAD_SPEED
	return 1.0

const MAX_SHALLOW: int = 3

## Fire: given a burning cell, decide spread to a neighbor (seeded rng).
static func fire_spreads(rng: RandomNumberGenerator, target_mat: int) -> bool:
	if not is_flammable(target_mat):
		return false
	return rng.randf() < FIRE_SPREAD_CHANCE

## Water beats fire: a cell with water can't burn and extinguishes fire.
static func extinguished(water_lvl: int) -> bool:
	return water_lvl > 0
