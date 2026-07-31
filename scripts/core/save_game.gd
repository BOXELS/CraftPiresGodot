class_name SaveGame
extends RefCounted
## Save/load: serializes the voxel shard (columns + heights), per-civ resources,
## and unit/building state to a compact dictionary written as JSON. The shard is
## already column-packed bytes, so this stays small.

const SAVE_PATH: String = "user://savegame.json"

static func save(world: WorldBuilder, units: UnitManager, seed_value: int) -> bool:
	var data: Dictionary = {
		"version": 1,
		"seed": seed_value,
		"resources": Events.get_civ_resources(&"player"),
		"heights": _pack_heights(world.shard),
		"columns": _pack_columns(world.shard),
		"peasants": _pack_peasants(units),
	}
	var f := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if f == null:
		push_error("SaveGame: cannot open %s for write" % SAVE_PATH)
		return false
	f.store_string(JSON.stringify(data))
	f.close()
	return true

static func load_save() -> Dictionary:
	if not FileAccess.file_exists(SAVE_PATH):
		return {}
	var f := FileAccess.open(SAVE_PATH, FileAccess.READ)
	var text: String = f.get_as_text()
	f.close()
	var parsed: Variant = JSON.parse_string(text)
	return parsed if parsed is Dictionary else {}

static func has_save() -> bool:
	return FileAccess.file_exists(SAVE_PATH)

static func apply_resources(data: Dictionary) -> void:
	Events.reset()
	var res: Dictionary = data.get("resources", {})
	for kind in res:
		Events.add_resource(&"player", StringName(kind), int(res[kind]))

static func _pack_heights(shard: VoxelShard) -> Array:
	var out: Array = []
	out.resize(VoxelShard.SIZE_X * VoxelShard.SIZE_Z)
	for i in VoxelShard.SIZE_X * VoxelShard.SIZE_Z:
		out[i] = shard.heights[i]
	return out

static func _pack_columns(shard: VoxelShard) -> Array:
	# Each column is a PackedByteArray; store as base64-ish via Array of ints.
	var out: Array = []
	for i in VoxelShard.SIZE_X * VoxelShard.SIZE_Z:
		var col: PackedByteArray = shard._columns[i]
		var arr: Array = []
		arr.resize(VoxelShard.MAX_Y)
		for y in VoxelShard.MAX_Y:
			arr[y] = col[y]
		out.append(arr)
	return out

static func _pack_peasants(units: UnitManager) -> Array:
	var out: Array = []
	for p in units.peasants:
		if not is_instance_valid(p):
			continue
		out.append({
			"pos": [p.position.x, p.position.y, p.position.z],
			"stage": p.stage,
			"tool": str(p.tool),
			"civ": str(p.civ_id),
		})
	return out
