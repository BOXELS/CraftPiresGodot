class_name HallOfLegends
extends RefCounted
## Permanent record of season winners (Phase 11). Inducts a civ at season end
## with its win condition, prestige score, and stats; persists to disk so legends
## survive across seasons and sessions.

const HALL_PATH: String = "user://hall_of_legends.json"
static var TEST_PATH: String = ""

var entries: Array = []

func _init() -> void:
	_load()

func _path() -> String:
	return TEST_PATH if TEST_PATH != "" else HALL_PATH

func induct(season_number: int, civ: StringName, condition: StringName, prestige: int, stats: Dictionary) -> void:
	entries.append({
		"season": season_number,
		"civ": str(civ),
		"condition": str(condition),
		"prestige": prestige,
		"stats": stats,
	})
	_save()

func champions() -> Array:
	# One entry per season winner.
	return entries

func titles_for(civ: StringName) -> int:
	var n: int = 0
	for e in entries:
		if e.get("civ") == str(civ):
			n += 1
	return n

func most_titles() -> StringName:
	var counts: Dictionary = {}
	for e in entries:
		var c: String = e.get("civ", "")
		counts[c] = int(counts.get(c, 0)) + 1
	var best: StringName = &""
	var best_n: int = 0
	for c in counts:
		if int(counts[c]) > best_n:
			best_n = int(counts[c])
			best = StringName(c)
	return best

func _save() -> void:
	var f := FileAccess.open(_path(), FileAccess.WRITE)
	if f == null:
		return
	f.store_string(JSON.stringify({"entries": entries}))
	f.close()

func _load() -> void:
	entries = []
	if not FileAccess.file_exists(_path()):
		return
	var f := FileAccess.open(_path(), FileAccess.READ)
	var parsed: Variant = JSON.parse_string(f.get_as_text())
	f.close()
	if parsed is Dictionary:
		entries = parsed.get("entries", [])
