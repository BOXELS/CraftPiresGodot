class_name Territory
extends RefCounted
## Territory claim (Phase 6): buildings project a claim radius. Tiles inside a
## civ's claim are "owned" — construction is only allowed on owned or neutral
## tiles, and the claim grows as more buildings complete (Keep has the widest).

const SIZE_X: int = VoxelShard.SIZE_X
const SIZE_Z: int = VoxelShard.SIZE_Z

# Claim radius per building kind.
const CLAIM_RADIUS: Dictionary = {
	&"keep": 18,
	&"house": 6,
	&"storehouse": 8,
	&"watchtower": 12,
}

var civ_id: StringName = &"player"
var _claim: PackedByteArray = PackedByteArray()   # 1 = owned by this civ
var _claims: Array = []                            # [{x,z,radius}] for recompute

func _init(p_civ: StringName = &"player") -> void:
	civ_id = p_civ
	_claim.resize(SIZE_X * SIZE_Z)
	_claim.fill(0)

static func index(x: int, z: int) -> int:
	return z * SIZE_X + x

func add_claim(cx: int, cz: int, building_kind: StringName) -> void:
	var radius: int = int(CLAIM_RADIUS.get(building_kind, 6))
	_claims.append({"x": cx, "z": cz, "radius": radius})
	_recompute()

func _recompute() -> void:
	_claim.fill(0)
	for c in _claims:
		_stamp(int(c["x"]), int(c["z"]), int(c["radius"]))

func _stamp(cx: int, cz: int, radius: int) -> void:
	for dx in range(-radius, radius + 1):
		for dz in range(-radius, radius + 1):
			if dx * dx + dz * dz > radius * radius:
				continue
			var x: int = cx + dx
			var z: int = cz + dz
			if x < 0 or x >= SIZE_X or z < 0 or z >= SIZE_Z:
				continue
			_claim[index(x, z)] = 1

func is_owned(x: int, z: int) -> bool:
	if x < 0 or x >= SIZE_X or z < 0 or z >= SIZE_Z:
		return false
	return _claim[index(x, z)] == 1

func can_build(x: int, z: int) -> bool:
	# Build inside your claim, or on neutral unclaimed tiles (expand outward).
	# Neutral = not owned by this civ; enemy overlap handled at placement time.
	return true  # Phase 6: allow anywhere; enforcement tightens with rivals in Phase 10

func owned_count() -> int:
	var n: int = 0
	for i in _claim.size():
		if _claim[i] == 1:
			n += 1
	return n
