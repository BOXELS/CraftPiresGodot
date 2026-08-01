# Godot ↔ Three.js MVP Parity

> Source of truth for bringing the Godot build up to the working Three.js MVP
> (`CursorApps/CraftPires/web/src` on the iMac). The MVP is the gameplay
> reference; this file tracks what is **ported**, **partial**, and **missing**
> in the Godot rebuild, and the order we're closing the gap.
>
> Formula: **AoE II + Settlers II + Empire Earth + Minecraft** (see
> `game-mechanics-summary.md`).

---

## Interaction model (the big one)

The MVP is a real RTS. The Godot build had almost none of this until recently.

| Feature | MVP (web) | Godot status |
| --- | --- | --- |
| Title / main menu | Live world behind, Free Play / Vs Bots / MP | **Done** — `MainMenu` overlays the world, Single Player starts the sim |
| Click select | LMB picks a unit | **Done** — `SelectionManager` (screen-proximity pick) |
| Box select | LMB drag rect | **Done** — `SelectionBox` + `units_in_box` |
| Shift add/remove | Shift+LMB toggles | **Done** |
| Double-click same type | LMB×2 = same kind+loadout on screen | **Done** — `select_same_on_screen` |
| Triple-click all type | LMB×3 = every unit of kind on screen | Partial — double-click only (no triple tier) |
| Smart right-click | RMB routed by target: move / gather / build / staff / attack | **Done** — `_issue_context_command` (soldiers attack-move, commander beam/move, peasants build/gather/dig) |
| Selection rings | ring under each selected unit | **Done** — torus ring per unit |
| Idle peasant cycle | `.` / `Shift+.` select + jump | **Done** |
| Select all peasants | Ctrl+A | **Done** |
| Select commander | Tab (again = jump camera) | **Done** |
| Help sheet | H toggles commands panel | Missing |
| Waypoint queue | Shift+RMB multi-flag route | Missing |
| Sprint (stamina) | Ctrl+RMB dash | Missing |
| F-mode possession | F takes direct WASD+mouse control of one unit | Partial — commander F-mode WASD only; no possess-any-unit, jump, crouch, mouse-look |

---

## Economy / Settlers logistics

| Feature | MVP (web) | Godot status |
| --- | --- | --- |
| Physical hauling to sites | peasants carry BOM to foundation | **Done** (Phase 4) |
| Construction phases | foundation → walls → roof → details | **Done** |
| Building staffing | workshops only produce while staffed | **Done** |
| Storage depots + caps | Keep / Storehouse / Yard hold stock | **Done** |
| Population cap | base + Keep + houses, age ceiling | Missing |
| Homestead spawning | staffed houses birth peasants (food cost, interval, lifetime max) | Missing |
| House rally + newborn duty | RMB rally; 0–4 newborn duty | Missing |
| Ground piles | felled trees / kills drop haulable piles | Missing |
| Food resource + animals | hunt wildlife → food piles | Missing |
| Sapling planting | plant fruit/plain trees inside claim | Missing |
| Dirt roads | drag-paint, +35% move speed | Missing |
| Transfer stock | depot → depot hauling | Missing |
| Commander supply line | peasants ferry commander cargo | Missing |

---

## Buildings (MVP registry → Godot `BuildingDefs`)

| MVP building | Godot |
| --- | --- |
| Keep / Town Center | `keep` |
| Small / Medium / Large House | `house` only (no tiers) |
| Small / Medium / Large Storehouse + Storage Yard | `storehouse` only |
| Watchtower | `watchtower` |
| Research Hall | Missing (tech via `T` only) |
| CraftSmith / Toolsmith / Weaponsmith | Missing |
| Dirt Road (pave) | Missing |

Build menu: MVP is **Settlement(1) → Keep/House/Storage/Roads**, **Defense(2) →
Watchtower**, **Crafting(3) → Hall/CraftSmith/Toolsmith/Weaponsmith**, with
folder drill-down and Esc-back. Godot has a 3-category bar (Econ/Military/
Wonder) — needs restructuring to match the MVP groups + tiers + roads.

---

## Tech / ages

| Feature | MVP (web) | Godot status |
| --- | --- | --- |
| 3 ages (Primitive → Metal → Gunpowder) | Age 1–2 in prototype | **Done** (3 ages) |
| Age-up gated by buildings + resources + pop | checklist (15 pop, Hall, smiths, store, 3 towers) | Partial (resources + buildings, no pop gate) |
| Tool research + hand-craft + smith mass-produce | Research Hall bench, racks | Partial (tools exist, no research bench / racks) |
| Peasant stage progression | Primitive → Road → Wheel → Advanced | **Done** |

---

## Already ahead of the MVP (Godot-only)

- Live voxel terraform (dig / raise) with re-mesh + collapse physics
- Water / mud / fire cellular sims + water rendering
- Season lifecycle + Hall of Legends
- Hold-Tab radial shortcut menu (cursor-anchored)
- Deterministic sim + 34-scenario headless test harness

---

## Port order (next phases)

1. **Population + homestead** — pop cap from houses, staffed houses birth
   peasants (food cost), rally points. *This is the core AoE2 loop.*
2. **Food + animals + piles** — hunt wildlife, felled trees drop haulable piles.
3. **Build menu restructure** — Settlement/Defense/Crafting groups, house +
   storage tiers, dirt-road paving with move-speed bonus.
4. **Waypoint queue + sprint** — Shift+RMB flags, Ctrl+RMB dash.
5. **F-mode possession** — possess any unit, mouse-look, jump, crouch.
6. **Help sheet (H)** — render the controls list in-game.
7. **Transfer stock + commander supply line** — depot↔depot, peasant ferries.
