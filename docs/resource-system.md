# Resource System

## Resource Tiers

### Common Resources (Always Relevant)

| Resource | Base Gather Rate | Primary Use | Properties |
|----------|-----------------|-------------|------------|
| **Wood** | 1.0/s | Fast early builds, fuel | Burns easily, low HP |
| **Stone** | 0.7/s | Walls, towers, foundations | High structure HP, slow to quarry |
| **Food** | Varies | Villager upkeep, unit training | From farms, animals, fishing |
| **Clay** | 0.6/s | Mid-tier buildings, pottery | Housing cap bonuses |
| **Iron** | 0.5/s | Gates, weapons, armor | Tiers 1-2 combat upgrades |
| **Coal** | 0.5/s | Smelting, fire arrows | Powers furnaces, craft speed aura |

### Rare Resources (Limited Power)

| Resource | Gather Rate | Spawn Weight | Primary Use |
|----------|-------------|--------------|-------------|
| **Gold** | 0.25/s | 8/chunk | Markets, high-tier research, elite units |
| **Diamond** | 0.1/s | 2/chunk | Late-game siege, tower crit resistance |
| **Emerald** | 0.15/s | 4/chunk | Diplomacy/market perks, trader speed |
| **Obsidian** | 0.08/s | 2/chunk | Fire resistance, wonder components |

### Special Crafted Resources

| Resource | Recipe | Use |
|----------|--------|-----|
| **Gunpowder** | Flint + Coal + Sulfur | Explosives, muskets, cannons |
| **Soldier's Rations** | Food + Salt/Coal | +10% move speed for 5 min |
| **Fortified Mortar** | Stone + Clay + Coal | +15% siege damage for 3 min |

## Biome Distribution

Resources spawn based on biome type with multipliers:

### Mountains
- Stone: ×1.5
- Iron: ×1.4
- Gold: ×1.2
- Food: ×0.6

### Plains
- Food: ×1.6
- Wood: ×1.3
- Stone: ×0.8

### Forest
- Wood: ×2.0
- Food: ×1.2
- Stone: ×0.7

### Swamp
- Clay: ×2.2
- Wood: ×1.2
- Food: ×1.0
- Iron: ×0.7

### Volcanic
- Obsidian: ×2.5
- Coal: ×1.6
- Diamond: ×1.4
- Food: ×0.4

## Material → Stat Conversions

### Walls
```
HP = base × (Stone_factor + Iron_trim × 0.15 + Obsidian_inset × 0.25)
```

### Gates
```
Armor = base × (Iron × 0.3 + Diamond_pins × 0.15)
```

### Towers
```
Fire_Resist = 1 + (Obsidian_inset × 0.2)
Crit_Resist = 1 + (Diamond_inlay × 0.1)
```

### Market Buildings
```
Tax_reduction = -5% per Emerald_ledger (cap -15%)
```

### Smelters/Forges
```
Craft_speed = +10% per Coal_stack in radius (cap +30%)
```

## Food System

### Farms
- **Cost**: 1 Food (seed)
- **Growth time**: 6 real minutes (base)
- **Harvest yield**: 12 Food
- **Upgrades**:
  - Irrigation (river adjacent): -25% growth time
  - Mills: +20% harvest yield

### Livestock Pens
- **Growth time**: 8 minutes
- **Yield**: 30 Food
- **Risk**: Can be raided

### Fishing Huts
- **Location**: Coasts/rivers
- **Yield**: Steady trickle
- **Nature**: Contested hotspots

### Upkeep
- Villager: 0.2 Food/min
- Military: 0.4 Food/min
- **Starvation debuff**: -20% work rate if <10 mins of food banked

## Resource Physicality

### Voxel Clumps
- Resources exist as **fine-grain voxel clumps** (10×10×10 micro-voxels)
- Commander beam mines clumps from deposits
- Clumps can be:
  - Stored in buildings (physical storage)
  - Transported by units
  - Used to construct buildings
  - Loaded into siege weapons
  - Dropped when buildings are destroyed

### Building as Resource Bank
When you build a structure with:
- 800 stone
- 200 wood
- 50 iron

That structure **contains** those materials physically. When destroyed:
- 60-70% drops as collectible clumps
- Can be mined by victor or defender
- Materials return to economy

### Loss Mechanics
- **Destruction loss**: 30-40% of materials lost (prevents infinite recycling)
- **Transport loss**: Minimal (1-5% if units are killed)
- **Storage loss**: None (buildings preserve resources)

### Storage Capacity (Settlers 3 rule — confirmed 2026-07-05)

You cannot endlessly hoard: every depot has a **hard capacity**, and growing
the stockpile means building more storage (the risk-strategy layer — storage
is territory to defend).

- Prototype **per-kind** caps (tunable feel defaults, 2026-07-14): each depot
  applies a **mineral** max and a **soft** max **per resource kind** (kinds do
  not share one pool — full wood does not block food). Mineral class = wood,
  stone, dirt (+ future ores); soft = food, saplings (+ future non-minerals).
  | Building | Mineral each | Soft each |
  | --- | --- | --- |
  | Keep (Age 0 start) | 100 | 150 |
  | Small Storehouse | 25 | 50 |
  | Medium Storehouse | 40 | 80 |
  | Large Storehouse | 60 | 120 |
  | Storage Yard | 15 | 25 |
  Larger sizes / ages get a **% increase** over Small (Medium/Large interim
  above until the age table is locked). HUD shows the **focused settlement**
  totals (each Keep is its own economy — stock never pools across Keeps); each
  building holds **separate physical stock** that must be hauled between depots
  (and later between settlements). Early wood pressure is intentional — build
  more storage for mineral kinds.
- **Staffing gate (confirmed 2026-07-05)**: a Storehouse only accepts stock while a
  storekeeper is assigned. The storekeeper **shuttles** resources from other
  depots (and ground piles at Yards) into that building's own inventory.
- **Shuttle balance (confirmed 2026-07-14)**: storekeepers prefer the **Keep** as
  donor, then the richest peer. They only pull a kind when the source **leads**
  the destination by more than a small hysteresis band, and each trip moves at
  most half the lead (midpoint equalize, capped by carry). This stops two
  staffed Storehouses from endlessly trading the same apples back and forth.
- **Per-depot stock (confirmed 2026-07-06)**: the Keep, each Storehouse, and each
  Yard hold **separate** wood/stone/food/dirt/sapling tallies. New hauls route
  to the nearest depot with **that kind's** headroom **in that unit's
  settlement** (`homeKeepId`). Construction carriers **withdraw** from the
  nearest depot in the **site's** settlement. Building a new Storehouse does
  not free space until peasants move stock into it.
- **Per-settlement stock (confirmed 2026-07-13)**: homestead births spend food
  from the house's Keep only (`SPAWN_FOOD_COST` = 25). Found Keep + inter-settlement
  haul / markets come later.
- **Saplings (confirmed 2026-07-13)**: felling (or fully draining) a tree drops
  **1–3 saplings** from wood volume + per-variant table (`TREE_SAPLING_RANGE`;
  always ≥1). Piles remember `treeVariant` (fruit / plain). Peasants haul
  wood → fruit → saplings into settlement stock.
- **Plant sapling (confirmed 2026-07-14)**: left Actions **Plant → Trees**
  (hotkey **2** / **P**) → **Fruit** or **Plain** tree type, then LMB grass
  **inside settlement claim** spends **1 sapling**
  (`ResourceField.plantSapling` with chosen variant). Settlement stock is still
  one `sapling` pool (variant choice is planting-time). **Plant at Feet** plants
  under the selected unit. Soft-reload is enough to see new trees.
- **Farm Actions (scaffold 2026-07-14)**: left Actions **Farm (3)** →
  **Grass** (needs **hoe** · food + seeds), **Fruit** (needs **loppers** · food
  + seeds), **Animal** (needs **knife** · food + wool / skins). Tool bases
  craft wooden→stone…; plot placement / production loop WIP. Farmer gear later
  raises farm speed.
- **Bone (confirmed 2026-07-14)**: base soft resource (`bone` soft slot). Killing
  wildlife drops **1–2 bone** piles (+ food). Bones unlock / feed crafting
  recipes (armor, tools, and other bone crafts — Hall / smiths as those land).
  **Bone meal** is a **refine** of bones (CraftSmith / station later) — not
  raw bone. Tree fert with bone meal comes after that refine recipe ships.
  Future: skeletons at night also drop bone.
- **Transfer Stock (confirmed 2026-07-14)**: peasants haul kinds from one
  staffed depot / Keep into another until nothing can move (player-ordered;
  separate from storekeeper equalization).
- **Haul trip size**: each peasant carries up to `Unit.carryCapacity` total
  units per trip (any mix; starter **5** via `PEASANT_CARRY`). Backpacks /
  research / wheelbarrows raise the per-unit field later. Supply-line ferry
  take size (`FERRY_CARRY`) is separate for now and may align with gear later.
  HUD selection shows Carry current/capacity.
- **Harvest levels (MC-style, confirmed 2026-07-14):** stone/cobble needs a
  **wooden+** pick; copper/iron ore need **stone+**; gold/diamond need
  **iron+**; obsidian needs **diamond+**. Wrong tool → no yield. Commander
  beam ignores. See `docs/crafting-tools-system.md` and
  `HARVEST_REQUIREMENT` in `scripts/units/tools.gd`.
- **Overflow**: when all depots are full, a hauler either **piles the load on
  the ground** beside the depot or **waits** with it (player setting).
  Ground piles are world objects — collectible later, and stealable by
  enemies once warfare lands.
- **Drop on interrupt/death**: a carrier that loses its task (or dies, once
  combat exists) drops its load as a ground pile where it stood — enemy
  raiders can rob supply lines by ambushing porters.
- Cheap outdoor **Storage Yards** (10 wood, 5 stone, build bar **Settlement →
  Storage → 4**) add **15 mineral / 25 soft** per kind when a yard hand is
  assigned; the hand automatically hauls loose ground piles within 40m into
  the yard's stock (Settlers 3 overflow recovery).
- **Size tiers (Settlers 3):** Settlement → **House** → Small / Medium / Large;
  Settlement → **Storage** → Small / Medium / Large Storehouse + Yard. Medium
  unlocks at Age 2, Large at Age 3 (`minAge`); locked tiers stay listed but
  cannot be placed.

## Resource Strategy Archetypes

### Diamond Kingdom
- **Strategy**: Nearly impenetrable walls, flashy monuments
- **Weakness**: Resource-hungry, slow expansion
- **Playstyle**: Defensive turtle, quality over quantity

### Dirt Horde
- **Strategy**: Cheap endless spam, dirt trebuchets
- **Weakness**: Fragile structures, easily breached
- **Playstyle**: Zerg rush, overwhelming numbers

### Emerald Traders
- **Strategy**: Market dominance, diplomacy bonuses
- **Weakness**: Weak defenses if not investing in military
- **Playstyle**: Economic victory, alliance building

### Coal/Iron Industry
- **Strategy**: Blackened fortresses, fire weapons, siege
- **Weakness**: Vulnerable to raids before fortified
- **Playstyle**: Industrial might, siege warfare

### Water Civilization
- **Strategy**: River redirection, moats, flood traps
- **Weakness**: Requires specific terrain
- **Playstyle**: Environmental manipulation, defensive

## Balance Guardrails

### Rare Resource Caps
- Tower crit resist: cap 30%
- Market tax floor: 2% minimum
- Fire resist: cap 50%
- Diamond/emerald/obsidian buff specialization, not raw DPS

### Resource Substitutes
- If no volcanic biome near spawn, add minor obsidian veins to caves
- Every shard remains viable with different resource paths

### Economic Sinks
- Repairs cost resources
- Upkeep drains food/gold
- Raid licenses cost resources
- Caravan/market fees
- Siege ammunition consumption

