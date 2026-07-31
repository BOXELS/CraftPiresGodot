# CraftPires — Development Guide

**Repository:** [github.com/BOXELS/CraftPires](https://github.com/BOXELS/CraftPires)

This doc is for humans and AI agents working in the repo. Game *design* lives in the other
`docs/*.md` files; this file covers *how we build*.

---

## Active stack

| What | Where |
| --- | --- |
| Playable game | repo root — **Godot 4.7** project (`project.godot`, GDScript) |
| Scenes | `scenes/` (`main.tscn` is the run target) |
| Scripts | `scripts/` (`core/`, `world/`, `units/`, `buildings/`, `ui/`) |
| Data resources | `data/` (`.tres` — materials, tool types, civ defs) |
| Scenario tests | `tests/scenarios/` |
| Design docs | `docs/` |
| Cursor rules | `.cursor/rules/` |

See also: [`godot-build-plan.md`](./godot-build-plan.md) (phase roadmap),
[`web-rebuild-notes.md`](./web-rebuild-notes.md) (Godot build log),
[`technical-architecture.md`](./technical-architecture.md).

---

## Quick start (Godot)

1. Install **Godot 4.7** (standard build).
2. Open the repo root in the Godot Project Manager (it contains `project.godot`).
3. Press **F5** to run the main scene.

Engine config already set in `project.godot`:

- Renderer: **Forward Plus**
- 3D physics: **Jolt Physics**
- Windows rendering driver: `d3d12`

**Headless parse/import check (CI):**

```bash
godot --headless --path . --quit
```

---

## Playtest builds

Desktop export presets (Windows / macOS / Linux) live in `export_presets.cfg`; distribute
zipped exports to testers. Scenario suites work in exported builds the same as in-editor
(`--scenario=<name>` CLI arg, or the in-game debug menu).

Future stack split: headless Godot dedicated servers per shard · Supabase (Boxels) for
auth/saves — not required for the single-player prototype.

---

## Controls & invariants

- **Single source of truth for bindings:** `scripts/core/controls.gd` on top of Godot's
  `InputMap` (HUD help reads from it). Remapping / DB persistence:
  [`controls-customization.md`](./controls-customization.md).
- **Load-bearing design rules:** `.cursor/rules/craftpires-design-invariants.mdc`

Do not remove documented behaviors (commander cargo, Shift+LMB gather, standing orders,
stall bail, x-ray occluded units, etc.) without user confirmation and matching doc updates.

---

## Scenario regression suite

Self-contained test scenes under `tests/scenarios/`, runnable in-editor or headless:

```bash
godot --headless --path . --scenario=tools
```

`mine` · `beam` · `sprint` · `bodyslam` · `yeet` · `persist` · `ferry` · `aura` · `build` ·
`path` · `tools` · `smith` · `storage` · `fell` · `staffing` · `collapse`

Run these after gameplay or pathing changes.

---

## Agent / multi-session workflow

1. Read [`godot-build-plan.md`](./godot-build-plan.md) for the current phase, and the
   latest entries in [`web-rebuild-notes.md`](./web-rebuild-notes.md) for what recently
   landed or is WIP.
2. After confirmed changes: append a dated entry to the Godot build log in
   `docs/web-rebuild-notes.md`.
3. Keep diffs small and scoped — prefer extending existing systems over rewrites.

---

## Legacy prototypes (reference only)

- **Three.js web prototype** (July 2026) — retired with the Godot rebuild. Its build log
  ([`web-rebuild-notes.md`](./web-rebuild-notes.md)) was reset for the Godot effort.
  Behaviors documented across `docs/` (controls, scenarios, unit physics) are the *spec*
  the Godot rebuild ports forward; the TypeScript code itself is not reused.
- **Unity 6 prototype** — pre-web history. Ignore unless explicitly asked.

---

## Contributing

1. Branch from `main` for feature work.
2. Ensure the project parses headless (`godot --headless --path . --quit`) before opening a PR.
3. Update design docs when behavior intentionally changes.
4. Do not commit `.godot/`, exported builds, or `user://` data.
