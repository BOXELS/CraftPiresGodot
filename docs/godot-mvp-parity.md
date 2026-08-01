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
| Smart right-click | RMB routed by target: move / gather / build / staff / attack | **Done** — RMB = move (formation) / site = build; Shift+LMB = gather/dig/hunt (fixed Godot inversion) |
| Selection rings | ring under each selected unit | **Done** — torus ring per unit |
| Idle peasant cycle | `.` / `Shift+.` select + jump | **Done** |
| Select all peasants | Ctrl+A | **Done** |
| Select commander | Tab (again = jump camera) | **Done** |
| Help sheet | H toggles commands panel | **Done** — short categorized sheet (not the dense Three.js wall) |
| Waypoint queue | Shift+RMB multi-flag route | **Done** — peasant + commander queues |
| Sprint (stamina) | Ctrl+RMB dash | Missing |
| F-mode possession | F takes direct WASD+mouse control of one unit | **Done** — PossessController: any selected unit, mouse capture, clean F/Esc release |

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
| Dirt roads | drag-paint, +35% move speed | **Done** — paint mode stays armed, drag Bresenham stroke, seed starting dirt (Three.js shovel-gate was clunky) |
| Transfer stock | depot → depot hauling | Missing |
| Commander supply line | peasants ferry commander cargo | Missing |

---

## Buildings (MVP registry → Godot `BuildingDefs`)

| MVP building | Godot |
| --- | --- |
| Keep / Town Center | `keep` |
| Small / Medium / Large House | `house`, `house_medium`, `house_large` |
| Small / Medium Storehouse + Storage Yard | `storehouse`, `storehouse_medium`, `storageyard` |
| Watchtower | `watchtower` |
| Research Hall | `researchhall` |
| CraftSmith / Toolsmith / Weaponsmith | `toolsmith`, `weaponsmith` (CraftSmith later) |
| Dirt Road (pave) | **Done** — Settlement → Roads → Dirt Road |

Build menu: **Settlement(1) → Keep/House/Storage/Roads**, **Defense(2) →
Watchtower**, **Crafting(3) → Hall/Toolsmith/Weaponsmith**, with folder
drill-down and Esc-back. Visual bottom bar swaps in place (AoE2 / Three.js
MVP): name + cost + hotkey on each button; active place/pave stays highlighted.

---

## Tech / ages

| Feature | MVP (web) | Godot status |
| --- | --- | --- |
| 3 ages (Primitive → Metal → Gunpowder) | Age 1–2 in prototype | **Done** (3 ages) |
| Age-up gated by buildings + resources + pop | checklist (15 pop, Hall, smiths, store, 3 towers) | Partial (resources + buildings, no pop gate) |
| Tool research + hand-craft + smith mass-produce | Research Hall bench, racks | Partial (tools exist, no research bench / racks) |
| Peasant stage progression | Primitive → Road → Wheel → Advanced | **Done** |

---

## Build menu (AoE2 / Three.js MVP)

Godot now mirrors the MVP bottom bar (`#buildmenu` / `hud.ts`):

- Always-visible bottom-center **BuildBar** after Single Player starts
- Top: **Settlement [1] · Defense [2] · Crafting [3]**
- Drill swaps the row in place: **Back + crumb + items** (folders for House / Storage / Roads)
- Buttons show **name · cost · [hotkey]**; armed place/pave stays highlighted
- Esc backs one level; Esc again cancels armed place/pave

---

## Already ahead of the MVP (Godot-only)

- Live voxel terraform (dig / raise) with re-mesh + collapse physics
- Water / mud / fire cellular sims + water rendering
- Season lifecycle + Hall of Legends
- Hold-Tab radial shortcut menu (cursor-anchored)
- Deterministic sim + headless scenario harness
- Dirt-road paint stays armed for drag (vs MVP re-open between strokes)

---

## Port order (next phases)

1. **House rally + newborn duty** — RMB rally on selected house; 0–4 duty.
2. **Building staffing via RMB** — workshops / towers produce while staffed.
3. **Visual destination flags** — show queued waypoints for selected units.
4. **Transfer stock + commander supply line** — depot↔depot, peasant ferries.
5. **Research Hall bench / tool racks** — research → hand-craft → smith queue.
