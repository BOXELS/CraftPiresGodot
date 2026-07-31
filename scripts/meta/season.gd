class_name Season
extends RefCounted
## Season lifecycle (Phase 11): tracks season number + elapsed in-season time,
## ends the season, and archives winners into the Hall of Legends. One shard =
## one season in the full design; here we model a single shard's seasons.

signal season_ended(season_number: int)
signal season_started(season_number: int)

var season_number: int = 1
var elapsed_days: float = 0.0
var days_per_season: float = 365.0
# Real-time mapping for the prototype: 1 real second = 1 in-game day, so a full
# season is 365s here (the real game runs 365 real days).
var seconds_per_day: float = 1.0

var hall: HallOfLegends

func _init() -> void:
	hall = HallOfLegends.new()

func tick(delta_seconds: float) -> void:
	elapsed_days += delta_seconds / seconds_per_day
	if elapsed_days >= days_per_season:
		end_season()

func progress() -> float:
	return clampf(elapsed_days / days_per_season, 0.0, 1.0)

func end_season() -> void:
	season_ended.emit(season_number)

## Archive a winner and roll to the next season. Returns the new season number.
func reset_for_next(winner_civ: StringName, condition: StringName, prestige: int, stats: Dictionary) -> int:
	hall.induct(season_number, winner_civ, condition, prestige, stats)
	season_number += 1
	elapsed_days = 0.0
	season_started.emit(season_number)
	return season_number
