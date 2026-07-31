# Crafting & Tools System — The Tech Table

> Minecraft's crafting-and-durability loop fused with Settlers 3's physical
> logistics, feeding Empire Earth-style epoch progression. Nothing gathers
> fast without tools; no tool exists until someone crafted it from real
> materials at a real building; every tool wears out and must be replaced.

Confirmed design decisions (2026-07-05 review; F mode dual path 2026-07-13;
**base→tier craft ladder + shared craft sheet 2026-07-14**):

1. **MC-strict tool gating** — stone/ore yields NOTHING without a pickaxe of
   sufficient **harvest level** (wooden for stone; stone pick for iron ore;
   iron pick for diamond — see harvest table below). Commander beam ignores.
2. **Settlers 3 physical logistics** — peasants always walk to get what they
   need; tools sit on a visible rack at the workshop until someone collects them.
3. **Research BASE → hand-craft tiers → smiths** — Research Hall / craft sheet
   researches a **base type** only (Pickaxe, Axe, Shovel, Weapon, Paxel).
   Player **hand-crafts each material tier in order** (no skipping). Age gates
   the highest material. The *first* hand-craft of a finished recipe adds it to
   `unlockedRecipes` for Toolsmith / Weaponsmith mass production. Same set
   whether crafted at the Hall, the **centered craft sheet (C)**, or in F mode.
4. **Staffed buildings** — every production building requires at least one
   peasant working inside; each building has a max staff per epoch. (The
   Research Hall is the exception: player-operated, no staff.)
5. **Commander beam stays innate** (comeback doctrine) — upgradeable via tech,
   never a crafted item. Available in RTS *and* F mode as the Commander's
   long-range extract; tools are the close-range alternate.
6. **Durability = 3× Minecraft ratios** (gentler churn at prototype peasant counts).
7. **Prototype slice now**: fists + wooden + stone tiers (copper/iron/gold/diamond
   stubbed behind Age), shared craft sheet, Research Hall base research,
   Toolsmith / Weaponsmith auto-production after first craft, durability, auto-fetch.
8. **F mode** = possess Commander *or any peasant* (**F**). Embodied move /
   look + **same craft sheet as RTS (C)**. Dig/place/hotbar still later.
9. **Data-driven catalog** — `ToolBase` + `ToolType` rows (`baseId`, `tier`,
   `minAge`). Superadmin upserts via `upsertToolType` / `__game.tools`.
10. **Dual-path craft (AoE ↔ Minecraft)** — one craft sheet UI + Hall panel +
    smiths; CraftSmith still builds refine stations. Town wood/stone still pays
    craft until the refined-inventory pass.

---

## Dual-path crafting (AoE buildings ↔ craft sheet / F mode)

CraftPires hybrids **AoE II macro** and **Minecraft craft depth** as two
surfaces over **one catalog** (`scripts/units/crafting.gd` + `tools.gd`):

| Step | AoE path | Craft sheet (RTS or F) |
| --- | --- | --- |
| Gather raw wood/stone | Peasant / Commander orders | Possessed dig / beam (F) |
| Refine → sticks, cut wood, cobble | **CraftSmith** stations | Same refine recipes (inventory pass) |
| Research BASE type | **Research Hall** | Same sheet · Research button |
| Hand-craft material tiers | Hall list or **C** sheet | Centered MC 3×3 sheet (**C** / Craft icon) |
| Mass-produce | Toolsmith / Weaponsmith | After first hand-craft unlock |

**Craft sheet:** centered horizontally and vertically (`scripts/ui/craft_sheet.gd`).
Open with **C** or the Craft icon when a commander/peasant is selected, or in
F mode. Esc / C closes (in F mode Esc closes the sheet before releasing
possession). Bottom build bar stays buildings-only.

**Ladder:** after researching Pickaxe, craft wooden → stone → (Age 2) copper /
iron / gold → (Age 3) diamond. Cannot skip tiers. Research does **not** unlock
smiths — only the first hand-craft does.

**CraftSmith:** staffed workshop (max 2); place via **Crafting** (`3` → `2`).
Panel builds stations from `REFINE_STATIONS`. Stations do not yet
consume/produce stock counts — that is the next economy pass; Hall/sheet/smiths
still spend rolled-up town `cost` wood/stone.

## The gathering rules (MC-strict)

| Target | Fists | Axe | Pickaxe |
| --- | --- | --- | --- |
| Trees / wood blocks | ✅ very slow ("punching trees") | ✅ fast by tier | — |
| Grass / dirt / sand | shovel required for dirt stock | — | — |
| Stone / rock nodes | ❌ **no yield** | — | ✅ wooden+ |
| Copper / iron ore (future) | ❌ | — | ✅ **stone+** |
| Gold ore (future) | ❌ | — | ✅ **iron+** |
| Diamond (future) | ❌ | — | ✅ **iron+** |
| Obsidian (future) | ❌ | — | ✅ **diamond+** |

Harvest levels live in `HARVEST_REQUIREMENT` / `BLOCK_INFO.harvest_target`
(`scripts/units/tools.gd`, `scripts/world/palette.gd`). Wrong tool → no yield + toast.
Punching trees bootstraps wooden tools. The **Commander's beam ignores**
harvest gates (comeback doctrine).

## Tool tiers

Speed multiplier applies to the base gather time of the matching job.
Durability is uses-until-break (≈3× Minecraft's 59/131/250/32/1561 scale).

| Tier | Speed | Durability (uses) | Recipe (prototype) | Epoch |
| --- | --- | --- | --- | --- |
| Fists | 0.25× (wood), 0 on stone | ∞ | — | always |
| Wooden | 1.0× | ~180 | 3 wood | 1 (Primitive) |
| Stone | 1.5× | ~390 | 2 wood + 3 stone | 1 (Primitive) |
| Iron | 2.0× | ~750 | 2 wood + 3 iron | 2 (Metal) — future |
| Gold | 3.0× | ~100 (fast but fragile, MC-style) | 2 wood + 3 gold | 2 — future |
| Diamond | 3.5× | ~4700 | 2 wood + 3 diamond | 3 — future |
| Emerald | 4.0× | ~6000 | 2 wood + 3 emerald | 3 — future |

Tool kinds in the prototype: **axe** (trees/wood), **pickaxe** (stone/ore),
**shovel** (grass/dirt → dirt stock for Dirt Roads), **weapon** (hunt / fight),
**hoe** (grass farms), **loppers** (fruit / orchard farms), **knife** (animal
husbandry — Weaponsmith after research). Higher material tiers farm / work
faster (wooden → stone → …). Future: hammer (building speed), fishing rod.
Weapons and armor follow the same tier table for combat stats (fists = weakest
defense; docs/warfare-system.md pass will consume this).

## The Tech Table / Research Hall (building path)

A buildable building for **base research** and optional hand-crafts (same rules
as the craft sheet).

- **Built like any building** (commander marks foundation, peasants haul + hammer).
- **Player-operated, no staff**: research a BASE (Pickaxe, Axe, …), then
  hand-craft tiers; finished tools land on the Hall rack.
- **Base research** → `researchedBases` (does **not** unlock smiths).
- **Recipe unlock** → first hand-craft of that finished `ToolType.id` →
  `unlockedRecipes` for Toolsmith / Weaponsmith.
- **Craft sheet (C)** is the Minecraft-feel surface; Hall panel is the AoE
  convenience list over the same state.
- **Age gate**: `ToolType.minAge` hides / locks copper+ until Age 2, diamond Age 3.

## The Toolsmith (trained peasant production)

A separate staffed workshop that mass-produces **only recipes the player has
already unlocked** (Research Hall panel *or* F-mode first craft — same set).

- **Must be staffed**: ≥1 trained peasant, max staff scales per epoch
  (Age 1: max 3). Shift+LMB or RMB the finished Toolsmith with peasants
  selected to train them as toolsmiths — they walk inside and become its
  workers, Settlers 3 style. This is the general staffing rule: every
  working building needs at least one peasant (Storehouse 1, Watchtower 1),
  and an unstaffed building doesn't produce/function.
- **Auto-stock**: keeps a small standing stock of each unlocked tool queued
  (prototype: 2 of each). Produces the best unlocked tier per kind.
- **Physical materials**: smiths walk to the Keep/Storehouse, carry the
  recipe's materials back, then craft over a work timer (hammering animation).
  No materials teleport.
- **The rack**: finished tools appear on a visible rack beside the building.
  Tools on the rack are world objects — takeable, and later lootable/burnable
  by enemies (raiding a toolsmith hurts, exactly like Settlers).

## Peasant tool logic

- **Slots**: each peasant has one tool slot per kind (axe, pickaxe, shovel,
  weapon, hoe, loppers, knife).
- **Auto-fetch**: when a peasant takes a gather/dig job and a better/required tool
  sits on a reachable rack, they walk to the rack first, equip, then work.
  If no tool exists: wood jobs proceed with fists (slow); stone jobs are
  refused with a "no pickaxe available" toast.
- **Durability**: −1 per work tick; at 0 the tool breaks (puff + toast), the
  peasant reverts to fists, and auto-fetch sends them for a replacement when
  one exists.
- **Visible equipment**: equipped tool renders in the peasant's hand
  (tier-colored head so a diamond axe reads at a glance).
- **Player override**: selection panel shows the equipped tool + durability
  bar; a drop-tool action lets the player free the tool for someone else.

## Staffed-building rule (general, applies beyond the Tech Table)

From this pass forward, production buildings follow one rule set:

- Every production building needs **≥1 assigned peasant** to function.
- **Max staff per building per epoch** (Toolsmith: 2 in Age 1; future
  buildings define their own).
- Staff assignment = RMB a building with peasants selected (same convention
  as construction work).
- The Tech Table is player-operated (no staff); Storehouses/Keep remain
  passive (no staff needed) in the prototype.

## Prototype implementation map

| Piece | File | Notes |
| --- | --- | --- |
| Bases, tiers, harvest, unlocks | `scripts/units/tools.gd` | `ToolBase` / ladder / `researched_bases` / `unlocked_recipes` / harvest levels |
| Shared craft sheet | `scripts/ui/craft_sheet.gd` | Centered MC modal — RTS + F (**C**) |
| Tech Table building type | `scripts/buildings/buildings.gd` | player craft state (`start_player_craft`), rack rendering |
| Toolsmith building type | `scripts/buildings/buildings.gd` | staffable (Age 1 max 3), auto-stocks unlocked recipes |
| Staff task (train toolsmiths) | `scripts/units/units.gd` | `staff` task; smiths fetch materials + work the bench |
| Gather gating + durability | `scripts/units/units.gd` | gather/mine paths consult equipped tool |
| Auto-fetch task | `scripts/units/units.gd` | `fetchtool` task before gather when needed |
| Tech Table / Toolsmith panels | `scripts/ui/hud.gd` | craft buttons + NEW badges, staff count, rack contents |
| Scenario self-tests | `tests/scenarios/` | `--scenario=tools` (player craft → unlock → fetch → mine), `--scenario=smith` (toolsmith auto-production) |

## F mode (embodied craft & research)

**Name in product copy:** F mode (or “possessed” / “embodied”). Do not ship UI
strings that say “Minecraft mode.”

**Who:** any **single selected** unit the player can possess today — **Commander
or peasant**. Enter with **F** (or zoom-into-FP); leave with **F** / **Esc**.
RTS camera and orders resume on release (`camRig.snap()` — no cross-map swoop).

### Intent

F mode is a **parallel control + craft surface** for the same civilization
progress:

| Loop step | Building / RTS path | F mode path |
| --- | --- | --- |
| Gather wood/stone/food | Peasant orders / Commander beam | Possessed unit swings tools / beam / fists |
| Research a BASE | Research Hall panel | Same craft sheet (**C**) |
| Hand-craft tier (+ unlock smiths) | Hall list or craft sheet | Same craft sheet (**C**) |
| Make more tools | Toolsmith / Weaponsmith (staffed, unlocked only) | Keep crafting by hand *or* staff smiths |
| Place civic buildings | Commander foundation → haul → hammer | Still the Settlers path |

Same `researchedBases` / `unlockedRecipes`, same Age gates, same costs.
Choosing F mode never creates a soft-locked “solo” tech tree.

### Possession rules

- Task-AI for that unit is suspended (`unit.manual`) while possessed.
- **Locomotion (shipped):** WASD move, mouse look, **Space** jump, **Ctrl**
  run (stamina), **Shift** crouch. Help sheet swaps to F-mode bindings; build
  bar hides until release.
- **Commander in F mode:** cargo hold is the personal inventory; beam remains
  usable (innate); tools are optional close-range speed/quality; **body-check
  only while running (Ctrl)** — same giant radius / charge sweep as RTS
  Ctrl+RMB (works while the mesh is hidden in possession).
- **Peasant in F mode:** peasant radius and speed only — no commander charge
  or body-check. MC-strict tool gating still applies (no pickaxe → no stone).
  Equipped tools wear as today. Carry slots = personal haul.
- Other units keep running under RTS / standing orders — the town does not
  freeze because you possessed one worker.

### Manual research & craft (shared craft sheet)

**C** (or Craft icon) opens the **same centered craft sheet** as RTS selection.
Esc closes the sheet first; a second Esc (or F) releases possession.

1. **Research base** — pay `ToolBase.researchCost` from town stock (prototype);
   on complete → `researchedBases`.
2. **Hand-craft tier** — pay `ToolType.cost`; on complete → tool to nearest Hall
   rack when available, and `unlockRecipe` on first craft for that id.
3. **Weapons / tools** feed Weaponsmith / Toolsmith the same way.

Later: spend commander cargo / peasant carry preferentially; hotbar equip;
refined mats block spends. Do not invent a second unlock table.

### What F mode does *not* replace

- **Population / houses / staffing** — still Settlers.
- **Depot capacity & haul** — still physical.
- **Comeback beam** — still innate on Commander.
- **AoE II macro** — F is optional; idle-villager hotkeys, Tab, box select,
  house multi-rally remain the RTS spine.

### Prototype status

- **Shipped:** F possession loco chrome; **shared craft sheet (C)** RTS + F;
  Hall **base research**; hand-craft tier ladder + Age stubs; unlock smiths on
  **first hand-craft**; harvest-level helpers; CraftSmith stations; shared
  `craftRecipe` grids.
- **Not shipped yet:** refined material inventory / cargo spends, hotbar,
  block place, full ore veins for copper/iron/diamond, 3rd-person follow cam.

### Superadmin tool catalog (data-driven recipes)

**Goal:** as superadmin you can create or edit **any** tool combination —
rename the wooden pickaxe, buff a stone sword, invent a **paxel** (axe +
pickaxe + weapon in one), set default name, resource costs, durability,
speed, research time, craft time, shop routing, and which jobs it can do.

**Single registry.** Research Hall, F-mode craft, Toolsmith, and Weaponsmith
all read `TOOL_TYPES` in `scripts/units/tools.gd`. There is no shadow list.

**Schema (`ToolType`):**

| Field | Purpose |
| --- | --- |
| `id` | Stable key (`wooden_paxel`) |
| `name` | Display name |
| `kind` | Primary slot / default mesh (`axe` \| `pickaxe` \| `weapon` \| `shovel`) |
| `capabilities` | Jobs the tool can do — omit for `[kind]`; paxel = `['axe','pickaxe','weapon']` |
| `baseId` | Family researched at Hall (`pickaxe`, `axe`, …) |
| `tier` | `wooden` … `diamond` \| `custom` (ladder order) |
| `minAge` | Age gate for this material tier |
| `speed` | Gather multiplier vs wooden baseline |
| `durability` | Uses until break |
| `cost` / `craftTime` | Hand-craft / smith pay (town wood/stone until inventory pass) |
| `craftRecipe` | 3×3 grid + ingredients (craft sheet + Hall hover) |
| `color` | UI / tool-head tint |
| `shop` | `toolsmith` \| `weaponsmith` \| `both` \| `none` |
| `enabled` | Hide without deleting |
| `blurb` | Admin notes |

**Materials / stations** live in `scripts/units/crafting.gd`: `sticks`,
`cut_wood` (Saw Mill), `cobble` (Stone Cutter).

**Costs** are a flexible bag (`wood` / `stone` / `food` optional) so new
resources plug in without a schema rewrite.

**API (prototype):**

```js
// Browser console — same object as window.__game.tools
__game.tools.upsert({
  id: 'iron_paxel',
  kind: 'pickaxe',
  baseId: 'paxel',
  capabilities: ['axe', 'pickaxe', 'weapon'],
  tier: 'iron',
  minAge: 2,
  name: 'Iron Paxel',
  speed: 1.8,
  durability: 800,
  cost: { wood: 4, stone: 12 },
  craftTime: 14,
  color: '#9aa4b2',
  shop: 'both',
  craftRecipe: { grid: Array(9).fill(null), ingredients: [] },
  blurb: 'Superadmin combo tool',
});
__game.tools.researchBase('paxel');
__game.tools.unlock('iron_paxel'); // mass-prod unlock (normally first hand-craft)
__game.tools.list();
```

**Later:** Boxels/Supabase-backed CMS UI for the same `upsert_tool_type` (per-civ
or global defs). Multiplayer: catalog + unlocks are civ state
(`multiplayer-design.md`).

**Seed example:** `wooden_paxel` ships in the catalog so multi-capability is
playable without console edits.

## Balance starting points (tune in playtests)

- Base tree chop: 0.55 s/tick with wooden axe (current feel) → fists 2.2 s/tick.
- Stone node: 0.85 s/tick with wooden pickaxe → stone pickaxe 0.57 s/tick.
- Craft time: 6 s per wooden tool, 9 s per stone tool (plus material walk time).
- Tech Table cost: 25 wood + 10 stone, 3 hauls, 8 s hammering.
- Toolsmith cost: 35 wood + 15 stone, 4 hauls, 10 s hammering.
- Toolsmith standing stock default: 2 per unlocked tool kind (player
  adjustable 0–4 later).

## Multiplayer checklist (per multiplayer-design.md)

- **Who owns it?** Tools and racks belong to the civ; equipped tool belongs to
  the peasant carrying it.
- **What order triggers it?** `orderStaff(building)`, queue mutations via
  building commands, `fetchTool` is an internal sub-task of gather orders.
- **Deterministic?** Craft timers and durability are frame-dt driven, no
  wall-clock, no unseeded randomness in yields.
- **What syncs?** Rack contents, queue state, staff assignment, each unit's
  equipped tool + durability.
- **Comeback doctrine?** Preserved — commander beam is toolless, and fists can
  always punch trees to restart the chain. F-mode craft uses the same unlock
  set as Research Hall (no shadow tech tree).
