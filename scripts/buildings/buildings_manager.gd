class_name BuildingsManager
extends Node3D
## Places construction sites, tracks active sites and completed buildings, and
## ticks construction. Completed sites become functional buildings (Phase 4
## covers Keep/House/Storehouse/Watchtower as voxel structures).

var shard: VoxelShard
var sites: Array = []          # active ConstructionSite
var completed: Array = []      # completed building kinds

signal site_completed_claim(kind: StringName, tile: Vector3i)

func setup(p_shard: VoxelShard) -> void:
	shard = p_shard

func place(kind: StringName, tile: Vector3i, civ: StringName = &"player") -> ConstructionSite:
	var site := ConstructionSite.new()
	add_child(site)
	var ground_y: int = shard.get_height(tile.x, tile.z)
	site.position = Vector3(tile.x, ground_y, tile.z)
	site.setup(kind, civ, ground_y)
	site.completed.connect(_on_site_completed.bind(site))
	sites.append(site)
	return site

func _ready() -> void:
	if not Sim.tick.is_connected(_on_tick):
		Sim.tick.connect(_on_tick)

func _on_tick(_i: int) -> void:
	for s in sites:
		if is_instance_valid(s):
			s.build_tick(Sim.TICK_INTERVAL)

func _on_site_completed(kind: StringName, site: ConstructionSite) -> void:
	completed.append(kind)
	sites.erase(site)
	var tile := Vector3i(int(site.position.x), 0, int(site.position.z))
	site_completed_claim.emit(kind, tile)

func active_site_needing_material(civ: StringName) -> ConstructionSite:
	for s in sites:
		if is_instance_valid(s) and s.civ_id == civ and not s.is_fully_stocked():
			return s
	return null

func site_count() -> int:
	return sites.size()

## Nearest active construction site whose footprint contains / is near a point.
## Used by context commands (RMB on a site = haul + build).
func site_near(pos: Vector3, radius: float = 4.0) -> ConstructionSite:
	var best: ConstructionSite = null
	var best_d: float = radius * radius
	for s in sites:
		if not is_instance_valid(s):
			continue
		var d: float = Vector2(s.position.x, s.position.z).distance_squared_to(Vector2(pos.x, pos.z))
		if d < best_d:
			best_d = d
			best = s
	return best
