# Quick Reference Guide

This is a comprehensive TL;DR of all CraftPires systems. For detailed information, see the full documentation.

---

## Core Game Formula

**Age of Empires II + The Settlers II + Empire Earth + Minecraft**

- **AoE II**: Unlimited peasants (housing-limited), resource gathering, military training
- **Settlers II**: Physical material hauling, supply chains, visible construction
- **Empire Earth**: 3 ages (Primitive → Metal → Gunpowder/Crystal), tech trees
- **Minecraft**: Voxel building, physics creativity (water+dirt=mud), terrain modification

---

## World Structure

### Shards (Separate Game Instances)
- **Size**: 512×512×256m per shard
- **Capacity**: 50 civilizations per shard (500+ potential players)
- **Named**: "Shard Alpha", "Shard Beta", "Shard Genesis"
- **Cross-shard travel**: Can move between shards
- **Season**: 365 days per shard, then reset

### Scale Per Shard
- **50 civilizations** maximum
- **1 Commander per civ** (strategic control)
- **0-9 human peasants per civ** (optional co-op)
- **Unlimited AI peasants per civ** (housing-limited, like AoE II)
- **Total**: 50-500+ humans, thousands of AI peasants

---

## Team Structure

### Solo Play
- **1 Commander** controls unlimited AI peasants
- Like playing AoE II singleplayer

### Co-Op Play (2-10 Humans)
- **1 Commander** (strategic control, beam mining)
- **Up to 9 human peasants** (each player controls ONE peasant)
- **Unlimited AI peasants** (Commander controls all)
- **Voice chat** for coordination

---

## Peasant System (AoE II-Style)

### AI Peasants (Unlimited)
- **Housing-limited**: Build houses for +5 population each
- **Commander-controlled**: Select, assign, hotkeys (like AoE II)
- **Roles**: Miners, builders, farmers, lumberjacks, soldiers
- **Auto-task finding**: Idle peasants find work automatically

### Human Peasants (0-9 Optional)
- **Player characters**: Each human controls ONE peasant
- **Specialized roles**: Miner, builder, warrior, scout, farmer, engineer, diplomat, saboteur
- **First/third-person control**: WASD movement, direct actions
- **Team coordination**: Voice chat, specialized expertise

### Peasant Progression (4 Stages)
1. **Primitive**: Wooden tools, 10 unit capacity, slow
2. **Road-Building**: Iron tools, 20 units, moderate, can build roads
3. **Wheel-Discovering**: Steel tools, 50 units (carts), fast
4. **Advanced**: Diamond tools, 100 units (hovercrafts), very fast

---

## Commander System

### Core Abilities
- **Beam mining**: 2× gathering speed (Dune-style laser)
- **Fast building**: 2× construction speed
- **Strategic control**: Commands all AI peasants
- **Command aura**: +10% morale/work rate to nearby units

### Stats
- **Base**: HP 300, Damage 30, Armor 10
- **Fully upgraded**: HP 600, Damage 50, Armor 25
- **Tough but mortal**: Can be killed in coordinated attacks

### Death & Respawn
- **Cost**: 500 food + 300 stone + 200 gold + 5 minutes
- **Unlimited respawns**: No maximum limit
- **Enemy capture**: Enemies can steal voxel pieces, rebuild as Sub-Commander
- **Consequences**: −10% work rate, −20% combat effectiveness, no beam mining

---

## Building System (Settlers II-Style)

### NO PREFABS - All Voxel Construction

**Process:**
1. **Commander places foundation** (marks location)
2. **Game calculates materials** (bill of materials)
3. **Peasants gather from storage** (wood, stone, etc.)
4. **Peasants physically carry** materials to site (visible voxel clumps)
5. **Peasants build in stages** (foundation → walls → roof → complete)
6. **Building functional** at 100% complete

**Construction Time:**
- **Small house**: 2-5 minutes (4 peasants)
- **Town Center**: 25-45 minutes (16 peasants)
- **Wonder**: Weeks to months (50+ peasants)

**Transport Efficiency:**
- **Walking**: 1.0× speed
- **Roads**: 1.5× speed (Age 2+)
- **Carts**: 2.0× speed (Age 3)
- **Hovercrafts**: 3.0× speed (Age 3 + Industrial Logistics)

---

## Resource System

### Common Materials (80-100 per chunk)
- **Wood**: Forests, surface
- **Stone**: Mountains, underground
- **Dirt**: Surface layer
- **Food**: Farms, hunting, fishing

### Uncommon Materials (20-30 per chunk)
- **Clay**: Near water
- **Iron**: Underground (20-60m depth)
- **Coal**: Underground (10-50m depth)

### Rare Materials (5-10 per chunk)
- **Gold**: Deep underground (50-100m)
- **Obsidian**: Volcanic regions
- **Emerald**: Very deep (80-150m)

### Very Rare Materials (1-3 per chunk)
- **Diamond**: Extremely deep (100-200m)
- **Sapphire**: Rare gem nodes
- **Ruby**: Rare gem nodes

### Gathering Rates (per peasant per second)
- Wood: 1.0 | Stone: 0.7 | Iron: 0.5 | Coal: 0.5
- Gold: 0.25 | Diamond: 0.1 | Emerald: 0.15
- **Commander**: 2× all rates (beam mining)

---

## Tech Progression (Empire Earth-Style)

### Age 1: Primitive Age
- **Unlock**: Start of game (automatic)
- **Focus**: Basic survival, wood/stone tools
- **Key techs**: Masonry, Agriculture, Woodcrafting, Torchlight
- **Peasants**: Primitive stage (wooden tools, 10 capacity)

### Age 2: Metal Age
- **Unlock**: 500 food + 300 stone + Barracks + 5 minutes
- **Focus**: Iron weapons, siege warfare, economic growth
- **Key techs**: Metallurgy, Engineering, Coinage, Smelting, Fortification
- **Peasants**: Road-Building → Wheel-Discovering (iron/steel tools, carts)

### Age 3: Gunpowder/Crystal Age
- **Unlock**: 2,000 food + 1,500 stone + 500 gold + 100 iron + Castle + 15 minutes
- **Focus**: Explosive weapons, crystal powers, advanced infrastructure
- **Key techs**: Gunpowder, Alchemy, Industrial Logistics, Crystal Architecture, Hydrology
- **Peasants**: Advanced (diamond tools, hovercrafts, 100 capacity)

---

## Combat System

### Unit Types
- **Militia** (Age 1): Cheap, weak, wooden spears
- **Infantry** (Age 2): Medium cost, iron swords
- **Archers** (Age 2): Ranged, wooden bows
- **Cavalry** (Age 3): Expensive, fast, powerful
- **Siege Crew** (Age 2-3): Operate trebuchets, catapults

### Siege Weapons
- **Trebuchet**: Long range (50m), 15s reload, 500 resource ammo capacity
- **Catapult**: Medium range (35m), 10s reload, 300 resource ammo capacity
- **Ram**: Anti-gate, 5× damage to gates, requires 4 crew
- **Bombard** (Age 3): Gunpowder cannon, massive damage

### Commander Combat
- **Strengths**: High HP, tanky, fast, high damage
- **Weaknesses**: Vulnerable to siege, focused fire, traps, assassinations
- **Not invincible**: Can be killed with coordination

---

## Physics & Creativity

### Water Physics
- **Flow**: Downward priority, then sideways spread
- **Flooding**: Dam rivers, redirect to enemy territory
- **Mud**: Water + dirt = slow terrain (50% movement penalty)
- **Drowning**: Units die in deep water

### Fire Physics
- **Spread**: 10% chance per adjacent flammable voxel per second
- **Flammable**: Wood, wool, leaves, thatch
- **Fire-resistant**: Stone, clay, obsidian, iron
- **Burn time**: 30-60 seconds, then ash

### Gravity
- **Falling materials**: Dirt, sand, gravel fall if unsupported
- **Stable materials**: Stone, wood, iron stay in place
- **Collapse**: Unsupported structures fall, deal crushing damage

### Underground
- **Tunnels**: Carved from terrain, need support beams
- **Supports**: Wood (8m spacing), Stone (12m), Iron (20m)
- **Collapse**: Remove 30%+ supports = cave-in
- **Flooding**: Hit water table = flooding

---

## Victory Conditions

### 1. Prestige Victory (Most Common)
- **Formula**: Territory×2 + Combat×3 + Building×1.5 + Economy×1 + Wonder×5
- **Win**: Highest prestige at end of season (365 days)
- **Multiple paths**: Military, building, economy, diplomacy

### 2. Wonder Victory (Most Prestigious)
- **Build Wonder**: 5,000-50,000 materials, weeks to construct
- **Defend 30 days**: Everyone attacks you
- **High reward**: 5× prestige multiplier if successful
- **Rare**: 1-2 per season per shard

### 3. Elimination Victory (Most Dramatic)
- **Total conquest**: Destroy all enemy structures
- **Commander kill**: Capture all enemy Commander pieces
- **Claim territory**: Own entire region
- **Extremely rare**: Legendary status, 10,000+ prestige

---

## Offline & AI Automation

### 24/7 Gameplay (No Shields)
- **AI continues**: Peasants gather, build, defend
- **Customizable**: Set gather priority, build priority, defense stance
- **No immunity**: Can be attacked anytime (no raid windows)
- **Optional newbie protection**: Start at distance from others

### Offline Settings
- **Gather priority**: Wood, stone, food, or balanced
- **Build priority**: Which projects to complete first
- **Defense stance**: Aggressive, defensive, or retreat
- **Trade automation**: Auto-trade excess resources

---

## Season Structure

### Timeline
- **Duration**: 365 real-world days
- **Phase 1 (Months 1-2)**: Land rush, expansion, first conflicts
- **Phase 2 (Months 3-6)**: Military buildup, alliances, tech advancement
- **Phase 3 (Months 7-10)**: Major wars, wonder construction, sieges
- **Phase 4 (Months 11-12)**: Endgame, prestige race, final battles

### Season Reset
- **What resets**: Terrain, structures, resources, territory, tech, alliances
- **What persists**: Cosmetics, achievements, Hall of Legends, +10% starting bonus
- **New season**: Fresh procedural generation, players start over

---

## Material Properties

### Hit Points (HP) Multipliers
- Dirt: ×0.5 | Wood: ×0.8 | Clay: ×1.2
- Stone: ×1.5 | Iron: ×2.0 | Obsidian: ×2.5 | Diamond: ×3.0

### Armor (per 100 voxels)
- Stone: +2 | Iron: +8 | Obsidian: +5 | Diamond: +15
- **Max armor**: 50

### Fire Resistance
- Wood: −20% (more flammable)
- Stone: +10% | Clay: +15% | Iron: +20% | Obsidian: +40%
- **Max fire resist**: 75%

---

## Economy Basics

### Starting Resources
- **3 peasants** (spawn instantly)
- **100 wood** + **50 stone** + **50 food**
- **Commander** with beam mining

### Resource Storage
- **Town Center**: 10,000 units (all types)
- **Storage Pit**: 5,000 units (specific type)
- **Warehouse**: 20,000 units (all types)

### Population
- **Default cap**: 200 peasants (like AoE II)
- **Housing**: +5 per house, +10 per advanced house
- **Upkeep**: 0.2 food/min per peasant

---

## Key Hotkeys & Controls

### Commander (RTS Controls)
- **Select all idle peasants**: Idle worker button
- **Assign tasks**: Right-click (mine, build, attack)
- **Hotkey groups**: 1-9 for unit groups
- **Building placement**: Select building, click location

### Human Peasant (FPS/TPS Controls)
- **WASD**: Movement
- **E**: Interact (mine, build, open doors)
- **Q**: Drop/pickup items
- **Tab**: Inventory
- **1-5**: Hotbar (tools, weapons)

---

## Critical Differences from Other Games

### vs Age of Empires II
✅ Voxel terrain (not 2D sprites)
✅ Physics interactions (mud, water, gravity)
✅ Persistent world (year-long seasons)
✅ Team co-op (10 humans per civ)

### vs The Settlers II
✅ Combat-focused (not pure economy)
✅ Voxel freedom (any structure design)
✅ Multiplayer conflict (PvP warfare)
✅ Commander unit (hero character)

### vs Empire Earth
✅ Voxel construction (not 3D models)
✅ Material-based progression (not time-based)
✅ Physics creativity (not just combat)
✅ Persistent world (not match-based)

### vs Minecraft
✅ RTS strategy (not survival sandbox)
✅ Peasant workforce (not solo player)
✅ Age progression (not flat tech)
✅ Team coordination (10 players vs 1)

---

## Common Mistakes to Avoid

❌ **"Peasants are limited to 1-9 total"**
✅ **Unlimited AI peasants (housing-limited) + optional 0-9 human co-op**

❌ **"50 active players per region"**
✅ **50 civilizations per shard (500+ potential players)**

❌ **"Prefab buildings appear instantly"**
✅ **All voxel construction with Settlers-style physical hauling**

❌ **"World expands daily"**
✅ **Multiple separate shards, cross-shard travel**

❌ **"Offline shields protect you"**
✅ **24/7 gameplay with AI automation, no immunity**

❌ **"Max 5 Commander respawns"**
✅ **Unlimited respawns, costs resources + time**

---

## Getting Started

### First 10 Minutes
1. **Commander spawns** with starting resources
2. **Place Town Center** (100 wood + 50 stone)
3. **Train 3 peasants** (50 food each, total 150 food)
4. **Assign peasants**: 2 miners (wood), 1 farmer (food)
5. **Gather resources** until 150 wood + 50 stone
6. **Build first house** (+5 population)
7. **Train 2 more peasants** (1 stone miner, 1 lumberjack)

### First Hour
1. **Build 2-3 houses** (unlock population cap to 15-20 peasants)
2. **Train 10-15 peasants** (balanced: miners, lumberjacks, farmers)
3. **Build Storage Pit** (near resources for efficiency)
4. **Scout territory** (Commander or peasant explores)
5. **Build Barracks** (prepare for Age 2)
6. **Research Age 2** (500 food + 300 stone + 5 minutes)

### First Day
1. **Age 2 unlocked** (iron tools, siege weapons)
2. **Build walls** (basic defenses around Town Center)
3. **Train military** (militia → infantry conversion)
4. **Build Market** (trade with allies)
5. **Research techs** (Metallurgy, Smelting, or Coinage)
6. **Expand territory** (claim more resource nodes)

---

## Pro Tips

### Economy
- **Build storage near resources** (reduce peasant travel time)
- **Use roads** (1.5× transport speed once Age 2)
- **Balance gathering** (food shortage = starvation, everything stops)
- **Commander beam mines rare materials** (2× speed, most efficient)

### Military
- **Protect Commander** (death = −10% work rate, expensive respawn)
- **Counter-units matter** (infantry > archers > cavalry > infantry)
- **Siege is expensive** (but necessary for structure destruction)
- **High ground bonus** (+10% ranged damage)

### Building
- **Material choices matter** (diamond > iron > stone > wood > dirt)
- **Fire safety** (keep flammables away from torches)
- **Underground bases** (hidden, protected, but can collapse)
- **Logistics optimization** (centralized vs distributed storage)

### Tech
- **Specialize** (can't afford all Age 3 techs)
- **Environment matters** (desert = gunpowder, forest = alchemy)
- **Alliance tech sharing** (trade rare resources for tech unlocks)
- **Age timing** (fast Age 2 = military advantage, slow = economic boom)

---

## Performance Expectations

### Client
- **60 FPS minimum** (optimized greedy meshing)
- **<4GB RAM** (chunk loading + LOD)
- **View distance**: 256-512m (8-16 chunks)

### Server
- **20 TPS** (50ms tick rate)
- **50 civs per shard** (500+ players)
- **<100ms latency** (client prediction + server validation)

### Network
- **500 KB/s** during chunk loading
- **50 KB/s** ongoing (updates only)

---

## Links to Full Documentation

### Core Mechanics
- [game-mechanics-summary.md](./game-mechanics-summary.md) - Integration overview
- [core-concepts.md](./core-concepts.md) - Design philosophy
- [peasant-system.md](./peasant-system.md) - Complete peasant mechanics
- [commander-system.md](./commander-system.md) - Commander abilities
- [resource-system.md](./resource-system.md) - Materials and economy

### Building & World
- [building-construction.md](./building-construction.md) - Settlers-style construction
- [terrain-world.md](./terrain-world.md) - Voxels, shards, physics
- [seasonal-structure.md](./seasonal-structure.md) - Year-long seasons

### Combat & Tech
- [warfare-system.md](./warfare-system.md) - Combat mechanics
- [tech-progression.md](./tech-progression.md) - Empire Earth ages

### Advanced
- [logistics-warfare.md](./logistics-warfare.md) - Supply chain warfare
- [physics-creativity.md](./physics-creativity.md) - Water, mud, gravity, fire
- [customization-sandbox.md](./customization-sandbox.md) - Aesthetic creativity

### Technical
- [technical-implementation-plan.md](./technical-implementation-plan.md) - Voxel engine
- [balance-design.md](./balance-design.md) - Balance considerations

---

*AoE II + Settlers II + Empire Earth + Minecraft = CraftPires. One world, one year, infinite strategies.*
