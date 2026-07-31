# CraftPires — Godot Build Plan

> The phase roadmap for the **from-scratch Godot 4.7 build** at the repo root.
> Companion to [`web-rebuild-notes.md`](./web-rebuild-notes.md) (the dev log — what
> actually landed and why) and [`development.md`](./development.md) (repo workflow).
> Game *design* lives in the other `docs/*.md` files; this file is the *order we build in*.

---

## Current state (2026-07-31)

- `project.godot` exists at the repo root: **Godot 4.7**, **Forward Plus** renderer,
  **Jolt Physics**, `d3d12` on Windows. App name "CraftPires".
- **No code yet** — zero scenes, scripts, or resources. Everything below is TODO.
- `docs/` has been repointed from the retired Three.js web prototype to this build.
  Behaviors proven in the old prototype are the *spec*; no TypeScript carries over.

## Tooling & agent control

- **No Godot MCP server is configured** in this workspace — agents work by editing
  project files directly (`*.tscn`, `*.gd`, `project.godot`) and validating headlessly.
- Install Godot 4.7 and put the binary on `PATH` so agents and CI can run:
  `godot --headless --path . --quit` (parse/import check) and
  `godot --headless --path . --scenario=<name>` (regression suite).
- Optional: a community Godot MCP server can later give agents live editor control
  (run scenes, inspect the remote scene tree, screenshot).

---

## MVP definition

**Single-player, single 128×128×64 shard.** One Larpites civilization: a Commander,
AI peasants, voxel terrain you can mine, Settlers-style construction, crafting/tools,
fog of war, save/load. No networking in MVP — but every system follows the
[engineering ground rules](./multiplayer-design.md#engineering-ground-rules-godot-prototype)
so nothing is thrown away when multiplayer lands.

**Explicitly out of MVP:** multiplayer, warfare units, water flow sim, ages 2–3 content,
crypto economy, cross-shard travel, human-controlled peasant co-op mode.

---

## Target project structure

```
craft-pires/
├── project.godot            # Godot 4.7 — Forward+, Jolt (exists)
├── scenes/
│   ├── main.tscn            # Entry: menu → game
│   ├── game.tscn            # World + HUD root
│   └── units/  buildings/  ui/
├── scripts/
│   ├── core/                # controls.gd, rng.gd, events.gd (autoload), spatial_hash.gd
│   ├── world/               # voxel_shard.gd, chunk.gd, layer_mesher.gd, navigation.gd,
│   │                        # resources.gd, piles.gd, collapse.gd, claim.gd, fog.gd, palette.gd
│   ├── units/               # units.gd, commander.gd, tools.gd, crafting.gd, silly_physics.gd
│   ├── buildings/           # buildings.gd, place_preview.gd
│   ├── game/                # civilizations.gd, camera_rig.gd, scenarios.gd
│   └── ui/                  # hud.gd, craft_sheet.gd, menus
├── data/                    # .tres — materials, tool types, civ defs, building defs
├── tests/
│   └── scenarios/           # one test scene per scenario (see suite below)
└── assets/                  # textures, audio, fonts (procedural first, art later)
```

**Autoloads:** `Events` (signals + `add_resource`/`spend` funnel), `Sim` (deterministic
tick + seeded `RandomNumberGenerator`), `Controls` (InputMap defaults + `user://` overrides).

---

## Old prototype → Godot mapping

| Web prototype (spec) | Godot equivalent |
| --- | --- |
| 112² `Uint8Array` voxel world, 16³ chunks | `VoxelShard` (`PackedByteArray` columns) + 32×32 layer chunks (`scripts/world/`) |
| Hidden-face culling, flat vertex colors | `SurfaceTool`/`ArrayMesh` greedy meshing + vertex colors (`layer_mesher.gd`) |
| InstancedMesh buildings/trees | `MultiMeshInstance3D` |
| Flow-field nav (Dijkstra fields, LRU) | `navigation.gd` on the column grid (same algorithm; `NavigationAgent3D` only for local avoidance) |
| Spatial hash separation | `spatial_hash.gd` (uniform grid, rebuilt per tick) |
| Blend-shell capsule characters | `Node3D` rig of primitive meshes + `silly_physics.gd` modes |
| Fog of war `DataTexture` | `ImageTexture` updated from explored/sight `PackedByteArray`s, draped `MeshInstance3D` |
| WebAudio synth | Godot audio buses + `AudioStreamGenerator` |
| `localStorage` settings | `user://settings.cfg` (`ConfigFile`) |
| `?scenario=` URL param | `--scenario=` CLI arg (`OS.get_cmdline_user_args()`) |

---

## Phases

### Phase 0 — Scaffolding
- [ ] Folder layout above; `scenes/main.tscn` as run target (F5)
- [ ] Autoloads (`Events`, `Sim`, `Controls`) with stub APIs
- [ ] `--scenario=` CLI parsing + headless run script
- [ ] CI check: `godot --headless --path . --quit` passes

### Phase 1 — Voxel terrain + RTS camera
- [ ] `VoxelShard`: 128×128×64 column data, seeded procedural heightmap + materials
- [ ] `LayerMesher`: surface-layer greedy meshing per 32×32 chunk, vertex-colored
- [ ] `camera_rig.gd`: WASD/arrow pan, Q/E rotate, wheel zoom (pitch tied), MMB drag-pan
- [ ] Terrain raycast picker (build/mine target cursor)
- [ ] Scenarios: `path` (camera/nav smoke test)

### Phase 2 — Commander + resources
- [ ] `commander.gd`: movement, click-to-move, beam-gather (Shift+LMB), 100-unit cargo,
  auto-deposit at Keep
- [ ] `resources.gd`: block trees (two-stage fell → fragments → log piles) + boulders
- [ ] `piles.gd`: ground piles, merge/cap rules
- [ ] Scenarios: `mine`, `beam`, `fell`

### Phase 3 — Peasants + task AI
- [ ] `units.gd`: order API (`order_move`, `order_gather`, …) — commands are the boundary
- [ ] Task state machine: idle / move / gather→return / pickpile / haul / build / mine
- [ ] Standing orders (AoE2 continue-with-same-work), stall bail (3s no progress)
- [ ] `navigation.gd`: flow fields + spatial-hash separation; building footprints hard-blocked
- [ ] Scenarios: `sprint`, `ferry`, `aura`, `bodyslam`, `yeet`

### Phase 4 — Construction (Settlers-style)
- [ ] `buildings.gd`: site pad + scaffold → haul phase → hammer phase → complete
- [ ] Material ledger (`materials_delivered`), site board UI
- [ ] Storage: per-kind caps, depot rules, overflow piles/wait
- [ ] Staffing: operational gate, `staff` task, worker outfits
- [ ] Keep + House + Storehouse + Watchtower
- [ ] Scenarios: `build`, `storage`, `staffing`

### Phase 5 — Crafting & tools
- [ ] `tools.gd` single registry (`TOOL_TYPES`), harvest gating, durability
- [ ] Tech Table (player hand-craft → recipe unlock) + Toolsmith (staffed auto-production)
- [ ] `craft_sheet.gd` modal (**C**), HUD panels
- [ ] Scenarios: `tools`, `smith`

### Phase 6 — Fog, claim, save/load
- [ ] `fog.gd`: three-state fog, sight radii, minimap mask
- [ ] `claim.gd`: Keep/tower claim radii constants
- [ ] Save/load via `user://saves/` (`ConfigFile` or binary `FileAccess`); scenario `persist`
- [ ] Scenario `collapse` (P1 unsupported-block collapse)

### Phase 7 — Multiplayer (post-MVP)
- [ ] Per-civ state swap (`civId` on units/buildings; resources through the `Events` funnel)
- [ ] Headless dedicated server (`--headless` export) + `ENetMultiplayerPeer`
- [ ] RPC layer: orders client→server, delta state server→client, interest management
- [ ] Supabase **Boxels** project: `cp_`-prefixed tables (auth, saves, `cp_keybinds`)

---

## Scenario regression suite (target)

`mine` · `beam` · `sprint` · `bodyslam` · `yeet` · `persist` · `ferry` · `aura` ·
`build` · `path` · `tools` · `smith` · `storage` · `fell` · `staffing` · `collapse`

Each is a self-contained scene under `tests/scenarios/` that sets up state, runs the
sim, and reports pass/fail (in-game + headless exit code). Run after any gameplay or
pathing change.

## Working agreements

- Behaviors marked load-bearing in [`development.md`](./development.md#controls--invariants)
  are ported deliberately, one system at a time — never dropped silently.
- Every landed system appends a dated entry to the dev log in
  [`web-rebuild-notes.md`](./web-rebuild-notes.md#dev-log).
- Known hazards to watch (from the old prototype): height steps as soft nav costs vs
  hard blocks; ferry targets that move; storage-cap refresh timing; box-select
  projection on terrain height; camera-basis sign errors on strafe/drag-pan.
