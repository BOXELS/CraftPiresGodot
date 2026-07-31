class_name Health
extends RefCounted
## Hit points + armor for units and buildings. Emits via callables the owner
## wires up. Armor reduces incoming damage (flat, min 1).

signal damaged(amount: int, current: int)
signal died

var max_hp: int = 100
var hp: int = 100
var armor: int = 0

func _init(p_max: int = 100, p_armor: int = 0) -> void:
	max_hp = p_max
	hp = p_max
	armor = p_armor

func take_damage(raw: int) -> int:
	var dmg: int = maxi(raw - armor, 1)
	hp = maxi(hp - dmg, 0)
	damaged.emit(dmg, hp)
	if hp <= 0:
		died.emit()
	return dmg

func heal(amount: int) -> void:
	hp = mini(hp + amount, max_hp)

func is_alive() -> bool:
	return hp > 0

func fraction() -> float:
	return float(hp) / float(maxi(max_hp, 1))
