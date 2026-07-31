class_name SpatialHash
extends RefCounted
## Uniform-grid spatial hash rebuilt each tick for cheap neighbor queries and
## unit separation. Keeps hundreds of units from O(n^2) comparisons.

var cell_size: float = 2.0
var _cells: Dictionary = {}

func _init(p_cell_size: float = 2.0) -> void:
	cell_size = p_cell_size

func clear() -> void:
	_cells.clear()

func _key(pos: Vector3) -> Vector2i:
	return Vector2i(int(floor(pos.x / cell_size)), int(floor(pos.z / cell_size)))

func insert(unit: Node3D) -> void:
	var k := _key(unit.position)
	if not _cells.has(k):
		_cells[k] = []
	_cells[k].append(unit)

func neighbors(pos: Vector3, radius: float) -> Array:
	var result: Array = []
	var r: int = int(ceil(radius / cell_size))
	var base := _key(pos)
	for dx in range(-r, r + 1):
		for dz in range(-r, r + 1):
			var k := base + Vector2i(dx, dz)
			if _cells.has(k):
				for u in _cells[k]:
					var flat := Vector2(u.position.x - pos.x, u.position.z - pos.z).length()
					if flat <= radius:
						result.append(u)
	return result

## Push overlapping units apart. Returns a position offset for the given unit.
func separation(unit: Node3D, radius: float, strength: float) -> Vector3:
	var push := Vector3.ZERO
	for other in neighbors(unit.position, radius):
		if other == unit:
			continue
		var diff := Vector3(unit.position.x - other.position.x, 0.0, unit.position.z - other.position.z)
		var d: float = diff.length()
		if d < radius and d > 0.001:
			push += diff.normalized() * (radius - d) * strength
	return push
