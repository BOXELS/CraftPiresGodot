class_name MaterialInteractions
extends RefCounted
## Material combination rules (Phase 9). Water + dirt -> mud (slows units);
## fire spreads to flammable neighbors; water extinguishes fire. All queries are
## pure lookups over the grid + water overlay so outcomes stay deterministic.

const MUD_SLOW: float = 0.55       # movement multiplier on mud
const FIRE_SPREAD_CHANCE: float = 0.3

# Material ids (match VoxelShard): 1 grass, 2 dirt, 3 stone, 4 sand, 5 snow.
# Fire/mud are transient states tracked on the grid via meta maps.

static func is_flammable(mat: int) -> bool:
	return mat == 1 or mat == 2  # grass, dirt (trees handled by resources)

## Mud: a column with water on dirt/grass becomes mud — slows ground movement.
static func move_multiplier(water_lvl: int, ground_mat: int) -> float:
	if water_lvl > 0 and (ground_mat == 1 or ground_mat == 2):
		return MUD_SLOW
	if water_lvl > MAX_SHALLOW:
		return 0.4  # wading through deeper water
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
