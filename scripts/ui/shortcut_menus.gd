class_name ShortcutMenus
extends RefCounted
## Declarative data for the radial shortcut menu and the nested build bar.
## Pure data + builders so scenario tests can drive it without a viewport.

## Root radial: three categories. Build drills into building kinds; Actions and
## Settings open their own sub-levels. Each leaf has an id the controller handles.
static func radial_root() -> Dictionary:
	return {
		"title": "CraftPires",
		"items": [
			{"id": &"cat_build", "label": "Build", "submenu": {
				"title": "Build",
				"items": [
					{"id": &"place", "label": "House", "payload": &"house"},
					{"id": &"place", "label": "Storehouse", "payload": &"storehouse"},
					{"id": &"place", "label": "Watchtower", "payload": &"watchtower"},
					{"id": &"place", "label": "Keep", "payload": &"keep"},
				],
			}},
			{"id": &"cat_actions", "label": "Actions", "submenu": {
				"title": "Actions",
				"items": [
					{"id": &"attack_move", "label": "Attack Move"},
					{"id": &"terraform_dig", "label": "Terraform: Dig"},
					{"id": &"terraform_raise", "label": "Terraform: Raise"},
					{"id": &"train_soldier", "label": "Train Soldier"},
					{"id": &"select_army", "label": "Select Army"},
					{"id": &"stop_units", "label": "Stop / Cancel"},
				],
			}},
			{"id": &"cat_settings", "label": "Settings", "submenu": {
				"title": "Settings",
				"items": [
					{"id": &"toggle_mouse_mode", "label": "Mouse: RTS/F-mode"},
					{"id": &"gfx_high", "label": "Graphics: High"},
					{"id": &"gfx_medium", "label": "Graphics: Medium"},
					{"id": &"gfx_low", "label": "Graphics: Low"},
					{"id": &"save_game", "label": "Save Game"},
				],
			}},
		],
	}

## Nested build-bar rows (AoE2 drill-down). Top level = categories; each maps to
## a list of placeable building kinds. Hotkeys are per-depth (1..n).
static func build_bar_rows() -> Dictionary:
	return {
		&"economy": {"label": "Economy", "items": [&"house", &"storehouse"]},
		&"military": {"label": "Military", "items": [&"watchtower"]},
		&"wonder": {"label": "Wonder", "items": [&"keep"]},
	}
