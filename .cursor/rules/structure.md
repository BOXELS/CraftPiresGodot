---
description: Project folder structure and file placement for the Godot build.
alwaysApply: true
---

# Structure Rules

## Project layout

```
craft-pires/
├── project.godot              # Godot 4.7 — Forward+, Jolt
├── .cursor/rules/             # AI project rules (this folder)
├── docs/                      # Design + build plan (source of truth)
├── scenes/
│   ├── main.tscn              # Entry / menu → game (F5 run target)
│   ├── game.tscn              # World + HUD root
│   ├── units/
│   ├── buildings/
│   └── ui/
├── scripts/
│   ├── core/                  # controls.gd, rng helpers, events.gd, spatial_hash.gd
│   ├── world/                 # voxel_shard, chunk, layer_mesher, navigation, resources,
│   │                          # piles, collapse, claim, fog, palette
│   ├── units/                 # units, commander, tools, crafting, silly_physics
│   ├── buildings/             # buildings, place_preview
│   ├── game/                  # civilizations, camera_rig, scenarios
│   └── ui/                    # hud, craft_sheet, menus
├── data/                      # .tres — materials, tools, civs, buildings
├── tests/
│   └── scenarios/             # one scene per regression scenario
└── assets/                    # textures, audio, fonts (procedural first)
```

Autoloads (register in `project.godot`): `Events`, `Sim`, `Controls`.

## File placement rules

- New gameplay systems go under the matching `scripts/<domain>/` folder above — not a flat `scripts/` dump.
- New scenes go under `scenes/` mirroring the domain (`units/`, `buildings/`, `ui/`).
- Shared definitions and balance numbers → `data/*.tres` (or a small `data/` script resource), not buried in HUD scripts.
- Scenario tests → `tests/scenarios/<name>.tscn` (+ script). Name matches `--scenario=<name>`.
- Design docs → `docs/`. Build order → `docs/godot-build-plan.md`. Dev log → `docs/web-rebuild-notes.md`.
- Do **not** recreate `docs/docs/`, `web/`, or Unity project trees.

## Naming conventions

- Directories and files: `snake_case`.
- `class_name`: `PascalCase` matching the concept (`VoxelShard`, `LayerMesher`).
- Signals: `snake_case` past-tense or event style (`resource_added`, `order_completed`).
- Constants: `UPPER_SNAKE_CASE`.
- Input actions: stable names owned by `Controls` (see `docs/controls-customization.md`).

## When creating new files

1. Check whether an existing script/scene can be extended before adding a new file.
2. Never create files outside this layout without asking first.
3. If a new top-level directory is needed, propose it and explain why before creating it.
4. If a script exceeds ~300 lines of mixed responsibilities, split by concern (data vs AI vs view).

## Mapping from old web prototype (reference only)

| Old (`web/src/...`) | New |
| --- | --- |
| voxel / chunk / mesher | `scripts/world/` |
| units / commander / tools | `scripts/units/` |
| buildings / place preview | `scripts/buildings/` |
| fog / claim / navigation | `scripts/world/` + `navigation.gd` |
| HUD / craft sheet | `scripts/ui/` + `scenes/ui/` |
| `localStorage` settings | `user://settings.cfg` via `Controls` |
| `?scenario=` | `--scenario=` + `tests/scenarios/` |
