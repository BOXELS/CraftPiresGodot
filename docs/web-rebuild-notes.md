# Godot Rebuild Notes (July 2026)

Working notes for the **from-scratch Godot 4.7 build** at the repo root. Companion to
[`godot-build-plan.md`](./godot-build-plan.md) (the phase roadmap); this file tracks what
actually got built and why.

> **Reset notice (2026-07-31).** This file was previously the build log of the retired
> Three.js + TypeScript web prototype (`web/`, July 2026). The `docs/` folder was copied
> out of that project; the game is now being rebuilt from scratch in Godot, so this log
> restarts here. The nested old-project copy (`docs/docs/`) was removed. Treat the
> remaining `docs/` design docs as the behavioral *spec* the Godot build ports forward,
> not as reusable TypeScript.
>
> Earlier still: a Unity 6 prototype predates the web build. Also retired.

---

## Starting point

- **Engine:** Godot 4.7, Forward Plus renderer, Jolt Physics — configured in
  `project.godot` at the repo root (app name "CraftPires"). GDScript is the primary
  language; GDExtension/C++ is reserved for proven hot paths (voxel meshing is the
  likely first candidate).
- **No code yet:** no scenes, scripts, or resources exist. Everything gets appended to
  this log as it lands.
- **Build plan:** [`godot-build-plan.md`](./godot-build-plan.md) — MVP-first phases
  (terrain + camera → commander + peasants → construction → save/load → multiplayer
  later via ENet dedicated server + Supabase `cp_` tables).
- **Spec sources:** the design docs in `docs/` are engine-agnostic. Behaviors proven in
  the old prototypes (AoE2 controls, standing orders, stall bail, worker outfits, x-ray
  occluded units, the scenario suite, …) are ported forward deliberately, one system at
  a time, and logged here.

## How to log work

- Append a dated `### YYYY-MM-DD — title` entry under **Dev log** (newest last,
  matching the old file's convention).
- Note what landed, what was verified in the Godot editor, and what is WIP.
- Keep entries scoped; link the relevant design doc when behavior changes.

## Systems inventory

_None yet — the Godot project is empty. First entries will cover: project scaffolding
(`scenes/`, `scripts/`, autoloads), the voxel layer data (heightmap + surface layer per
32×32 chunk), RTS camera, and the first scenario test. See the build plan for the
intended order._

## Controls

_No Godot bindings exist yet. Defaults will follow
[`controls-customization.md`](./controls-customization.md) (AoE2-first priority,
Minecraft second) and live in `scripts/core/controls.gd` on top of Godot's `InputMap`;
this section mirrors them once implemented._

## Known issues

_None yet (no code). Carried-forward design hazards from the old prototype to watch
during the rebuild:_

- _Height steps as soft nav costs vs hard blocks (cliff gating)._
- _Ferry/supply-line targets that move (fresh path solves per cell crossed)._
- _Storage-cap refresh timing vs deposit acceptance._
- _Box-select projection must use terrain height, not logical unit y._
- _Camera-basis sign errors on strafe / drag-pan (bit the web build twice)._

## Dev log

### 2026-07-31 — Docs repointed at Godot; rebuild not started

- `docs/` rewritten for the from-scratch Godot 4.7 build: development guide, technical
  architecture, technical implementation plan, README stack section, and this log
  reset. Game-design content unchanged (engine-agnostic).
- New [`godot-build-plan.md`](./godot-build-plan.md): MVP definition (single-player,
  single 128×128 shard) and phased roadmap.
- No scenes/scripts yet — next step is Phase 0 scaffolding per the build plan.

### 2026-07-31 — Phase 0 scaffolding landed

- Full-plan roadmap agreed: single-player-first (economy → construction → ages →
  warfare → physics → seasons), procedural units only (blend-shells + code-generated
  outfit kits, no rigging). See `.cursor/plans/craftpires_full_godot_build_51a20d98.plan.md`.
- Godot MCP (`user-godot`) verified end-to-end: version 4.7.1 stable, project info,
  editor launch, run/stop + debug output. Godot CLI on PATH via
  `/Applications/Godot.app/Contents/MacOS/Godot` for headless checks.
- Project structure created per plan: `scenes/{units,buildings,ui}`, `scripts/{core,
  world,units,buildings,game,ui}`, `data/`, `tests/scenarios/`, `assets/`.
- Autoloads registered in `project.godot`: `Events` (signal bus + resource funnel
  with per-civ ledger), `Sim` (20 TPS deterministic tick + seeded RNG), `Controls`
  (InputMap defaults + `user://settings.cfg` overrides).
- `scenes/main.tscn` set as run scene; `--scenario=<name>` CLI harness loads
  `tests/scenarios/<name>.gd` on top of `ScenarioBase` (pass/fail + exit code).
- Verified: `godot --headless --path . --quit` parses clean; `-- --scenario=scaffold`
  passes 8/8 checks (autoloads, resource funnel, seeded RNG determinism) with zero
  warnings; `run_project` boots on Apple M4 Metal Forward+.
- WIP/next: Phase 1 — `VoxelShard` column data + `LayerMesher` + `camera_rig`.

### 2026-07-31 — Phase 1: voxel terrain + RTS camera

- `scripts/world/voxel_shard.gd`: 128×128×64 column world (`PackedByteArray`
  columns), seeded Perlin heightmap (8–40), grass/dirt/stone/sand materials,
  heightmap updates on dig.
- `scripts/world/layer_mesher.gd`: naive hidden-face-culled meshing per 32×32
  chunk via `SurfaceTool`, per-material vertex colors, generated normals.
  Greedy meshing deferred until profiling demands it.
- `scripts/game/camera_rig.gd`: WASD/arrow pan (camera-basis, zoom-scaled),
  Q/E rotate, wheel zoom with pitch tied to distance, MMB drag-pan.
- `scripts/world/world_builder.gd`: generates shard, meshes all 16 chunks,
  adds sun + procedural sky. `main.gd` now boots straight into the world.
- Controls registered in `Controls` autoload: `cam_pan_*`, `cam_rotate_*`,
  `craft_sheet`.
- Verified: `--scenario=path` passes 7/7 (generation, determinism, digging
  heightmap update, chunk meshing, camera rig), `--scenario=scaffold` still
  8/8, zero warnings, renders on Apple M4 Metal Forward+.
- Next: Phase 2 — blend-shell rig (`rig_blendshell.gd`, `silly_physics.gd`,
  `outfit_kit.gd`) + Commander + resources (block trees, boulders, piles).

### 2026-07-31 — Phase 2: procedural rigs + Commander + resources

- `scripts/units/rig_blendshell.gd`: primitive-mesh character rig (capsule
  torso/limbs, sphere head) with shoulder/hip pivots, team tint, parametric
  height/build/head. No Skeleton3D, no AnimationPlayer, no assets.
- `scripts/units/silly_physics.gd`: procedural animation modes (idle/walk/run/
  work/carry/tumble/combat-wobble) posing the rig per frame with math.
- `scripts/units/outfit_kit.gd`: code-generated outfits (peasant hat/backpack,
  commander helm+plume+pauldrons, soldier helm+shield) + tool props
  (axe/pick/spear) from primitive meshes, tier-colored per material.
- `scripts/units/commander.gd`: CharacterBody3D — click-to-move (raycast on
  terrain), Shift+LMB beam-gather (mines surface voxel, cargo 0/100, deposits),
  cyan beam visual, gold outfit. Terrain height from heightmap (collision
  disabled on chunk colliders to avoid sticking).
- `scripts/world/resources.gd`: block trees (trunk + canopy cubes) scattered
  on grass via seeded RNG. `world_builder.gd` now adds `StaticBody3D` trimesh
  colliders per chunk so terrain raycasting works.
- Scenario harness refactored: `ScenarioBase.setup()` runs as coroutine over
  real physics frames (`move_and_slide` needs the engine loop — manual
  `_physics_process` calls blocked headless). Fixed global class-name cache
  via `--import`; parse errors were cache-staleness, not real.
- Verified: full suite green — `scaffold` 8/8, `path` 7/7, `mine` 3/3,
  `beam` 7/7, `fell` 3/3, zero warnings. Visual: commander + trees render,
  HUD shows cargo counter. `screencapture` used for screenshots (macos-control
  `screenshot` tool returns empty against a running Godot process — note for
  later: use native screencapture).
- Next: Phase 3 — peasant units, `order_*` task AI, flow-field navigation,
  spatial-hash separation, worker outfit kits.

### 2026-07-31 — Phase 3: peasant task AI + separation

- `scripts/units/peasant.gd`: CharacterBody3D worker on the heightmap, carry
  state, `order_move`/`order_gather`/`order_idle` API (command boundary),
  wood-tier peasant outfit.
- `scripts/units/task_brain.gd`: task state machine (move / gather→haul→deposit
  standing order / idle), gather timing, AoE II-style stall-bail re-pathing.
- `scripts/core/spatial_hash.gd`: uniform-grid hash with `neighbors()` +
  `separation()` — keeps units from stacking at O(n) per tick.
- `scripts/units/unit_manager.gd`: spawns peasants, ticks brains on the
  deterministic `Sim.tick` (20 TPS), rebuilds the spatial hash, applies
  separation. Peasants are sim-driven, not frame-driven.
- `main.gd`: spawns 4 peasants near the commander and starts `Sim`.
- Verified: full 9-scenario suite green (42 checks) — sprint (move order),
  ferry (gather→haul→deposit standing order credits Events), aura (separation
  pushes overlapping units apart), bodyslam (spatial hash queries + push
  direction), yeet (tumble→land rig cycle). Zero warnings.
- Note: new `class_name` types require a `--import` run to register in
  `global_script_class_cache.cfg`; headless runs fail with "Could not find
  type" until then (same as Phase 2). Added to the phase workflow.
- Next: Phase 4 — Settlers-style construction (site pad, haul phase, hammer
  phase, storage caps, staffing), real drop point for the gather standing order.

### 2026-07-31 — Phase 4: Settlers-style construction

- `scripts/buildings/building_defs.gd`: type registry — keep / house /
  storehouse / watchtower with footprint, bill of materials (wood+stone),
  build time, scaffold color. Pure data, no assets.
- `scripts/buildings/construction_site.gd`: placed foundation. Tracks BOM +
  delivered materials, 4 phases (foundation/walls/roof/details), worker
  staffing, and renders a voxel scaffold that rises one block per phase.
  `deliver()` accepts materials up to need; `build_tick()` advances progress
  only while stocked AND staffed; diminishing-returns speed multiplier
  (1/1.8/2.5/3.5/4.0×) from the design doc.
- `scripts/buildings/storage_depot.gd`: per-civ stockpile with caps. Peasants
  deposit gathered resources in, hauling withdraws out — all through the
  `Events` funnel so accounting stays single-source. Storehouse buildings will
  raise caps later.
- `scripts/buildings/buildings_manager.gd`: places sites, ticks construction
  on `Sim.tick`, records completed buildings, finds sites needing material.
- `task_brain.gd`: two new orders — `haul` (go to depot → withdraw needed
  material → carry to site → deliver → repeat → auto-switch to `build` when
  stocked; waits if storage empty) and `build` (staff the site, work anim
  while construction advances). The real Settlers haul loop, wired into the
  same standing-order state machine as gather.
- `main.gd`: starting stockpile (80 wood / 40 stone), a `BuildingsManager`,
  and **B key** places a house foundation ahead of the commander and auto-sends
  the 3 nearest free peasants to haul+build it.
- Verified: 3 new scenarios green — `build` (peasant hauls from storage,
  builds a house through all phases to completion), `storage` (depot caps,
  deposit/withdraw round-trip through Events), `staffing` (no progress without
  workers, 1×/2.5× speed multiplier scaling). Full 13-scenario suite passing
  (66 checks), zero warnings. Fixed a duplicate-var parse error in main.gd.
- Next: Phase 5 — crafting, tools, peasant stage progression (primitive →
  road-building → wheel → advanced carry/speed tiers), tool racks in
  storehouses, outfit upgrades per stage.

### 2026-07-31 — Terrain regions + live terraform + Phase 5

**Terrain regions (user ask: flat areas + grouped hills/mountains).**
- `voxel_shard.gd` `generate()` rewritten: a very-low-frequency **region mask**
  (Simplex, freq 0.012) picks flat/hill/mountain zones; heights blend a gentle
  plains field (~9-13), rolling hills (17-27), and mountains (46-60) with wide
  `smoothstep` bands so transitions are soft foothills, not cliff lines. Peaks
  ≥40 get snow, ≥30 bare stone. Consistent across seeds (verified 1/999/424242).
- `--seed=<n>` and `--screenshot=<path.png>` CLI flags added to `main.gd` so
  terrain/layout can be rendered headlessly for visual checks (the macOS window
  capture route was unreliable; self-screenshot is the dev tool now).

**Live terraform (user ask: destroy/mine/dig/move terrain).**
- `world_builder.gd`: chunks now tracked in a dict; `edit_voxel/dig/raise`
  mutate the shard then re-mesh only the affected chunk(s) — including neighbor
  chunks across a 32×32 seam — and rebuild trimesh collision so raycasting
  stays true. Controls: RMB peasant-dig, Ctrl+RMB instant carve, Shift+RMB raise.
- Fixed a real bug: `set_material` only recalculated column height when
  *removing* blocks, never when *adding* — raising terrain silently did nothing.

**Phase 5 — crafting, tools, stage progression.**
- `scripts/units/peasant_stage.gd`: 4 tiers (Primitive/Road-Builder/Wheel/
  Advanced) with carry 10/20/50/100, speed, work multiplier, outfit tier.
- `scripts/units/tools.gd`: axe/pick/shovel/hammer — resource costs through
  Events, affordability gate, and a 1.4-1.5× effect multiplier on the matching
  task kind (pick→stone, shovel→dirt, axe→wood, hammer→build).
- `peasant.gd`: `stage`, `tool`, `set_stage()` (re-outfits per tier),
  `work_speed()` = stage×tool, `carry_capacity()/move_speed()` from stage.
  New `order_dig(pos, kind)` — the quarry/mine order.
- `task_brain.gd`: `dig` order — walk to the column, carve it via
  `world.dig()` each work cycle (time divided by stage×tool speed), fill carry,
  haul home, deposit through Events, repeat. Standing order like gather.
- `unit_manager.gd` passes `world` to peasants so they can carve terrain.
- Verified: 3 new scenarios green — `quarry` (peasant digs a real pit, terrain
  lowers, dirt credited), `stageup` (carry/speed/work scale per tier, tool
  stacks), `tools` (crafting cost/affordability/effect). Full **16-scenario
  suite passing**, zero warnings. Quarry-demo render shows 3 peasants digging a
  stepped pit into the plains.
- Next: Phase 6 — fog of war, territory claim, save/load, collapse physics
  (unsupported voxels fall). Then Phase 7 combat.
