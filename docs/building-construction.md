# Building & Construction System

## Overview

All construction in CraftPires is **100% voxel-based** with physical material delivery. Inspired by The Settlers II, peasants must physically carry materials from storage to construction sites, creating a satisfying and immersive building experience.

**No Prefabs. Everything is Voxels.**

---

## The Settlers II Building System

### Physical Material Hauling

**Core Process:**
1. **Commander places foundation** (marks building location on terrain)
2. **Game calculates materials** (bill of materials from voxel design)
3. **Peasants gather materials** from storage buildings (Town Center, Storage Pits)
4. **Peasants carry materials** to construction site (visible voxel clumps)
5. **Peasants build in stages** (Foundation → Walls → Roof → Complete)
6. **Building becomes functional** when 100% complete

**The Settlers Experience:**
- **Supply chains**: Watch materials flow from mines → storage → construction
- **Logistics planning**: Optimize transport routes for efficiency
- **Resource management**: Balance gathering vs construction
- **Peasant coordination**: Multiple workers needed for large projects
- **Satisfying visuals**: See your civilization grow voxel by voxel

### Material Transport Process

**Step-by-Step:**

**1. Material Gathering**
- Peasants go to nearest storage building
- Pick up required materials (wood, stone, etc.)
- Carry capacity depends on peasant stage:
  - Primitive: 10 units
  - Road-Building: 20 units
  - Wheel-Discovering: 50 units (with carts)
  - Advanced: 100 units (with hovercrafts)

**2. Transport to Site**
- Peasants walk from storage to construction site
- Transport speed depends on:
  - Peasant stage (primitive = slow, advanced = fast)
  - Roads (1.5× speed if roads exist)
  - Carts/hovercrafts (2-3× speed)
  - Terrain (uphill slower, downhill faster)

**3. Unload Materials**
- Peasants place materials at construction site
- Materials visible as stockpiles (voxel piles)
- Each construction phase needs specific materials

**4. Construction**
- Peasants use tools to build (pickaxe, hammer, etc.)
- Build in stages as materials arrive
- Visual progress (25%, 50%, 75%, 100%)

**5. Completion**
- Building becomes functional at 100%
- Peasants celebrate (animation)
- Building gains full stats (HP, armor, etc.)

### Construction Phases

**Phase 1: Foundation (25%)**
- **Materials needed**: Stone, dirt (base layer)
- **Time**: 20% of total build time
- **Visual**: Ground leveled, foundation voxels placed
- **Can be damaged**: Yes, but rare (enemies must actively attack)

**Phase 2: Walls (50%)**
- **Materials needed**: Wood, stone, clay (structural materials)
- **Time**: 40% of total build time
- **Visual**: Walls rise from foundation
- **Can be damaged**: Yes, enemies can attack partial walls

**Phase 3: Roof (75%)**
- **Materials needed**: Wood, thatch (roof materials)
- **Time**: 20% of total build time
- **Visual**: Roof structure visible, scaffolding
- **Can be damaged**: Yes, but harder to hit (higher up)

**Phase 4: Details (100%)**
- **Materials needed**: Decorative materials (optional)
- **Time**: 20% of total build time
- **Visual**: Windows, doors, decorations added
- **Functional**: Building activates (can train units, store resources, etc.)

### Build Speed

**Base Construction Rate:**
- **Primitive peasant**: 10 voxels/second
- **Road-Building peasant**: 15 voxels/second
- **Wheel-Discovering peasant**: 20 voxels/second
- **Advanced peasant**: 30 voxels/second
- **Commander**: 20 voxels/second (but 2× gathering speed)

**Multiple Workers (Diminishing Returns):**
- **1 peasant**: 1.0× speed (baseline)
- **2 peasants**: 1.8× speed
- **4 peasants**: 2.5× speed
- **8 peasants**: 3.5× speed
- **16+ peasants**: 4.0× speed (max efficiency, diminishing returns)

**Example Build Times:**
- **Small house** (1,000 voxels, 4 peasants): ~2 minutes
- **Medium house** (5,000 voxels, 8 peasants): ~8 minutes
- **Barracks** (10,000 voxels, 8 peasants): ~15 minutes
- **Town Center** (20,000 voxels, 16 peasants): ~25 minutes
- **Wonder** (500,000 voxels, 50 peasants): ~10 hours

### Transport Efficiency

**Travel Time (Major Factor):**
- **Walking**: 1.0× speed
- **Roads**: 1.5× speed (if Age 2+)
- **Carts**: 2.0× speed (if Age 3+)
- **Hovercrafts**: 3.0× speed (if Age 4)

**Strategic Placement:**
- **Build storage** near resource nodes (mines, forests)
- **Build construction sites** near storage (reduce travel time)
- **Use roads** to connect storage → construction sites
- **Minimize distance** for maximum efficiency

**Example:**
- **No roads**: Peasant takes 30 seconds to walk from storage to site (60s round trip)
- **With roads**: Peasant takes 20 seconds (40s round trip)
- **With carts**: Peasant takes 15 seconds (30s round trip)
- **Result**: 2× faster construction with proper logistics

---

## Building Design System

### Two Design Approaches

**1. Blueprint System (Custom Voxel Builds)**

**Sandbox Editor Mode:**
- **Separate build space**: Personal plot or isolated editor
- **Fine-grain voxel placement**: 0.1m³ scale voxels
- **Material palette**: All unlocked resources available
- **Size constraints**: Based on age tier (Feudal, Castle, Imperial)
- **Physics testing**: Test structural integrity before export

**Blueprint Export:**
- **Voxels → compact mesh**: Game optimizes voxel design into efficient mesh
- **Server validates**:
  - Size constraints (doesn't exceed age limits)
  - Material count (bill of materials calculated)
  - Banned shapes (no offensive symbols)
  - Structural integrity (optional: weight/support system)
- **Stats derived**: HP, armor, fire resistance calculated from materials used

**Example Blueprint Export:**
```json
{
  "id": "bp_custom_townhall_001",
  "name": "Emerald Townhall v2",
  "owner": "player_42",
  "dims": [18, 12, 14],
  "palette": ["air", "stone", "wood", "iron", "emerald"],
  "voxels_rle": "compressed_voxel_data",
  "bill_of_materials": {
    "stone": 980,
    "wood": 320,
    "iron": 120,
    "emerald": 15
  },
  "stats": {
    "hp": 38000,
    "armor": 16,
    "fire_resist": 0.15
  },
  "version": 1
}
```

**2. Standard Designs (Community Templates)**

**Balanced Templates:**
- **Basic house**: 100 wood + 50 stone (efficient ratio)
- **Town Center**: 500 stone + 200 wood (balanced stats)
- **Barracks**: 300 stone + 150 wood + 50 iron (military-focused)
- **Market**: 200 wood + 100 gold (trade-focused)

**How They Work:**
- **Pre-designed blueprints** created by community or developers
- **Optimized for balance**: Good HP/cost ratio, efficient shape
- **Still require hauling**: Peasants must carry materials to site
- **Still built in stages**: Foundation → Walls → Roof → Complete

**Difference from Prefabs:**
- ❌ NOT instant placement
- ❌ NOT magical appearance
- ✅ Still requires material hauling (Settlers-style)
- ✅ Still built voxel by voxel
- ✅ Can be interrupted/damaged during construction

### Real-World Placement

**Placement Process:**
1. **Commander selects blueprint** from library (custom or template)
2. **Commander clicks location** on terrain
3. **Game calculates terrain level** (flatten if needed)
4. **Game shows material requirements** (bill of materials)
5. **Commander confirms placement** (foundation marker appears)
6. **Peasants begin hauling** materials from storage
7. **Construction begins** once first materials arrive

**Placement Rules:**
- **Must be on valid terrain**: Can't place on water, lava, extreme slopes
- **Must have clearance**: No overlapping buildings
- **Must have resources**: Peasants need materials to start
- **Can be cancelled**: Commander can cancel before completion (refunds 100% materials)

---

## Material → Stats Formula

### Hit Points (HP)

```
Base HP = voxel_count × 10

Material Multipliers:
- Wood: ×0.8
- Dirt: ×0.5  
- Stone: ×1.5
- Clay: ×1.2
- Iron: ×2.0
- Obsidian: ×2.5
- Diamond: ×3.0

Final HP = Base × (weighted_avg_of_materials)
```

**Example:**
- **1,000 voxel house** (500 wood, 500 stone)
- Base HP = 1,000 × 10 = 10,000
- Weighted avg = (500×0.8 + 500×1.5) / 1,000 = 1.15
- Final HP = 10,000 × 1.15 = **11,500 HP**

### Armor (Damage Reduction)

```
Base Armor = 0

Material Bonuses:
- Stone: +2 per 100 voxels
- Iron: +8 per 100 voxels
- Diamond: +15 per 100 voxels
- Obsidian: +5 per 100 voxels

Max Armor = 50
```

**Example:**
- **1,000 voxel house** (500 stone, 500 iron)
- Stone armor = (500 / 100) × 2 = 10
- Iron armor = (500 / 100) × 8 = 40
- Total armor = 10 + 40 = **50 armor (capped)**

### Fire Resistance

```
Base = 0% (fully flammable)

Material Modifiers:
- Wood: -20% (more flammable)
- Stone: +10%
- Clay: +15%
- Obsidian: +40%
- Iron: +20%

Fire Resist = sum(material_percentages) / total_voxels
Max Fire Resist = 75%
```

**Example:**
- **1,000 voxel house** (500 wood, 500 stone)
- Wood resistance = 500 × -20% = -100
- Stone resistance = 500 × +10% = +50
- Total = (-100 + 50) / 1,000 = **-5% fire resistance (more flammable!)**

### Special Properties

**Aesthetic Budget:**
- **Decorative voxels** (colored glass, dyed wool, patterns) don't add stats
- **Limited to 10%** of total voxels
- **Allows style** without forcing inefficiency

**Example:**
- 1,000 voxel house can have 100 decorative voxels
- Remaining 900 voxels determine stats
- Player can make beautiful buildings without sacrificing strength

**Weight & Foundations:**
- **Heavy materials** (stone, iron, obsidian) require strong foundations
- **Foundation strength** = sum(base_layer_materials) / required_weight
- **Wood/dirt bases** can't support diamond towers (will collapse)
- **Stone/iron bases** can support heavy upper floors

---

## Building Types

### Core Structures

**Town Center**
- **Function**: Spawns peasants, stores resources (10,000 units), Commander respawn
- **Standard design**: 500 stone + 200 wood
- **Custom design**: Minimum 700 combined materials
- **Build time**: ~25 minutes (16 peasants)
- **Stats**: 15,000 HP, 15 armor, 10% fire resist

**House**
- **Function**: Increases population cap (+5 per house)
- **Standard design**: 100 wood + 50 stone
- **Custom design**: Minimum 100 combined materials
- **Build time**: ~2 minutes (4 peasants)
- **Stats**: 2,000 HP, 5 armor, 0% fire resist

**Barracks**
- **Function**: Trains military units (militia, infantry, archers)
- **Standard design**: 300 stone + 150 wood + 50 iron
- **Custom design**: Must include iron (minimum 50)
- **Build time**: ~15 minutes (8 peasants)
- **Stats**: 10,000 HP, 20 armor, 15% fire resist

**Market**
- **Function**: Trade resources, caravans, emerald bonuses reduce fees
- **Standard design**: 200 wood + 100 gold
- **Custom design**: Must include gold (minimum 50)
- **Build time**: ~10 minutes (8 peasants)
- **Stats**: 5,000 HP, 5 armor, 5% fire resist

**Storage Pit**
- **Function**: Stores specific resource type (5,000 units)
- **Standard design**: 150 wood + 100 stone
- **Custom design**: Minimum 200 combined materials
- **Build time**: ~5 minutes (4 peasants)
- **Stats**: 3,000 HP, 10 armor, 10% fire resist

**Walls & Gates**
- **Function**: Fortifications, territorial boundaries
- **Standard design**: 50 stone per segment
- **Custom design**: Any materials, length/height limited by tier
- **Build time**: ~1 minute per segment (2 peasants)
- **Stats**: Depends heavily on materials (diamond walls >> dirt walls)

**Towers**
- **Function**: Vision, defensive structure, archer garrison
- **Standard design**: 400 stone + 100 wood
- **Custom design**: Height limits by tier (10m → 25m → 50m)
- **Build time**: ~20 minutes (8 peasants)
- **Stats**: 12,000 HP, 25 armor, 10% fire resist

**Smelter/Forge**
- **Function**: Refines ores (iron ore → iron ingots), coal bonus (+10% speed)
- **Standard design**: 200 stone + 100 iron + 50 coal
- **Custom design**: Must include iron + coal slots
- **Build time**: ~12 minutes (8 peasants)
- **Stats**: 8,000 HP, 15 armor, 20% fire resist

### Special Structures

**Wonders**
- **Function**: Multi-week alliance projects, grants global buffs, victory condition
- **Design**: Custom build only (no standard design)
- **Requirements**: Exotic materials (diamonds, emeralds, obsidian)
- **Build time**: Weeks to months (50+ peasants)
- **Stats**: Massive HP (100,000+), high armor (40+), 50% fire resist

**Monuments**
- **Function**: Prestige buildings, respawn points, alliance rally markers
- **Design**: Custom build only (aesthetic encouraged)
- **Requirements**: Any materials, size limits apply
- **Build time**: Days to weeks
- **Stats**: Variable based on materials

**Shrines**
- **Function**: Secondary Commander respawn, garrison morale bonus
- **Standard design**: 150 stone + 50 gold
- **Custom design**: Any materials
- **Build time**: ~8 minutes (8 peasants)
- **Stats**: 5,000 HP, 10 armor, 15% fire resist

---

## Underground Construction

### Tunnel Networks

**Carved from Terrain:**
- **Not placed voxels**: Excavate existing terrain (subtract voxels)
- **Require support beams**: Wood or iron pillars at intervals
- **Without supports**: Cave-ins (terrain collapses)
- **Strategic uses**: Infiltration routes, surprise attacks, hidden bases

### Subterranean Bases

**Excavation Requirements:**
1. **Commander beam mines** or peasants dig out space
2. **Install support beams** at regular intervals
3. **Ceiling height limits** based on support strength:
   - Wood beams: 5m ceiling
   - Stone pillars: 10m ceiling
   - Iron pillars: 15m ceiling

**Benefits:**
- **Hidden from surface**: Can't be seen from above
- **Protected from siege**: Trebuchets can't hit underground
- **Surprise attack routes**: Tunnel under enemy walls
- **Climate control**: Underground farms grow faster

**Risks:**
- **Collapse from weight**: Too much above = collapse below
- **Collapse from explosives**: Enemy can trigger cave-ins
- **Flood if water breached**: Hit water table = flooding
- **Limited exits**: Trap if discovered (enemies block exits)

### Support System

**Pillar Spacing Requirements:**
- **Wood beams**: Every 8m
- **Stone pillars**: Every 12m
- **Iron pillars**: Every 20m

**Collapse Mechanics:**
- **Remove >30% supports**: Gradual collapse (5-minute warning)
- **Explosives**: Instant collapse (no warning)
- **Structures above**: Fall into void (massive damage)
- **Rubble**: Fills underground space (blocks tunnels)

**Example:**
- 100m tunnel needs 12 wood beams (every 8m) or 8 stone pillars (every 12m)
- Enemy destroys 4 wood beams = 33% removed = tunnel collapses
- Base above falls into void, entire civilization destroyed

---

## Logistics & Supply Chains

### Efficient Building Strategies

**Strategy 1: Centralized Storage**
- **Build Town Center** in center of territory
- **Build Storage Pits** near resource nodes (mines, forests)
- **Build roads** connecting storage to Town Center
- **Result**: Materials flow efficiently to construction sites near Town Center

**Strategy 2: Distributed Storage**
- **Build multiple Storage Pits** throughout territory
- **Assign peasants** to specific storage locations
- **Build near resources**: Construct buildings near materials
- **Result**: Reduced travel time, faster construction

**Strategy 3: Mobile Storage (Advanced)**
- **Use carts/hovercrafts** to transport bulk materials
- **Create supply depots** near frontline construction
- **Commander beam mines** rare materials, deposits at depot
- **Result**: Can build anywhere on map efficiently

### Construction Priority

**Early Game Priority:**
1. **Houses**: Unlock population (build 2-3 immediately)
2. **Storage Pits**: Store gathered materials
3. **Barracks**: Begin military training
4. **Walls**: Protect Town Center

**Mid Game Priority:**
1. **Market**: Enable trade
2. **Towers**: Vision and defense
3. **Advanced Houses**: More population
4. **Smelter/Forge**: Refine ores

**Late Game Priority:**
1. **Wonder**: Victory condition
2. **Monuments**: Prestige
3. **Mega-structures**: Alliance projects
4. **Underground bases**: Hidden strongholds

---

## Civilization Identity Through Building

### Visual Uniqueness

**Every custom building makes your civ distinct:**

**Clay Brick Civilization**
- **Aesthetic**: Reddish-brown structures, Mediterranean style
- **Stats**: Medium durability (clay ×1.2 HP multiplier)
- **Weaknesses**: Moderate fire resistance (clay +15%)

**Obsidian Fortress**
- **Aesthetic**: Dark, imposing, volcanic stronghold vibe
- **Stats**: Very high durability (obsidian ×2.5 HP multiplier)
- **Strengths**: Fire-resistant (obsidian +40%)

**Emerald Monuments**
- **Aesthetic**: Glittering green, trade empire aesthetic
- **Stats**: Medium durability (emerald used decoratively)
- **Strengths**: Trade bonuses (+10% market efficiency)

**Mixed-Material Pragmatists**
- **Aesthetic**: Patchwork defenses, function over form
- **Stats**: Variable (optimized per building purpose)
- **Strengths**: Efficient resource use

### Structural Storytelling

**Buildings tell your civilization's history:**

**Battle Scars:**
- **Repaired sections**: Different materials show where damage occurred
- **Patched walls**: Wood patches on stone walls (emergency repairs)
- **Material shortages**: Dirt walls next to stone (ran out of stone)

**Economic Progress:**
- **Early wood hovels**: First structures still standing
- **Later stone upgrades**: Upgraded buildings show growth
- **Diamond accents**: Late-game wealth on display

**War Trophies:**
- **Captured structures**: Enemy buildings rebuilt with your materials
- **Conquered territory**: Mix of your style + enemy ruins
- **Victory monuments**: Commemorate major battles

**Archaeological Sites:**
- **Ruins**: Collapsed buildings become terrain features
- **Season-end**: Entire map is historical artifact
- **Hall of Legends**: Screenshots preserve greatest builds

---

## Construction Challenges & Comedy

### Hilarious Failures

**The Great Wool Fire:**
- **Player spends days** gathering wool, dyeing it black
- **Builds gothic dark civ** with black wool decorations
- **Peasant lights torch** inside building
- **Entire civ burns** (wool is highly flammable)
- **Social media gold**: *"3 days of work, 3 minutes of fire"*

**The Flooded Basement:**
- **Player builds** underground base
- **Peasants dig too deep**, hit water table
- **Entire base floods** (water physics)
- **Peasants drown**, base destroyed
- **Lesson learned**: Check water table depth before digging

**The Collapsed Tower:**
- **Player builds** 50m diamond tower on dirt foundation
- **Foundation too weak** for diamond weight
- **Tower collapses**, crushes everything below
- **Materials lost**, peasants killed
- **Physics consequences**: Heavy materials need strong foundations

**The Abandoned Project:**
- **Player starts Wonder**, runs out of resources
- **Half-built Wonder** sits for weeks
- **Enemy raids**, steals materials from construction site
- **Wonder never completed**, monument to failure
- **Strategic lesson**: Don't start what you can't finish

### Realistic Consequences

**Material Delivery Failures:**
- **Storage too far**: Peasants take forever to haul materials
- **No roads**: Construction takes 2× longer
- **Enemy raids storage**: Materials stolen before delivery
- **Peasants die en route**: Carrying materials when attacked

**Construction Interruptions:**
- **Enemy attacks**: Damage partial buildings
- **Resource shortages**: Construction halts mid-build
- **Peasant death**: Workers killed, construction slows
- **Weather hazards**: Rain makes mud, slows building

**Design Flaws:**
- **No doors**: Peasants can't enter completed building
- **Too many windows**: Low HP, easy to break in
- **Flat roof**: Snow accumulates, roof collapses
- **No foundation**: Building sinks into soft terrain

---

## Balance Considerations

### Build Time vs Cost

**Small Buildings (Quick Construction):**
- **House**: 100-150 materials, 2-5 minutes
- **Storage Pit**: 150-250 materials, 5-8 minutes
- **Tower**: 400-500 materials, 15-25 minutes

**Medium Buildings (Moderate Construction):**
- **Barracks**: 500-700 materials, 15-30 minutes
- **Market**: 300-400 materials, 10-20 minutes
- **Town Center**: 700-1000 materials, 25-45 minutes

**Large Buildings (Long Construction):**
- **Wonder**: 5,000-50,000 materials, weeks to months
- **Mega-fortress**: 10,000-100,000 materials, days to weeks
- **Underground base**: Variable (excavation time)

### Size Limits by Age

**Feudal Age (Age 1):**
- **Max dimensions**: 15×15×10m
- **Max voxels**: 10,000
- **Examples**: Houses, storage pits, small barracks

**Castle Age (Age 2):**
- **Max dimensions**: 30×25×15m
- **Max voxels**: 50,000
- **Examples**: Town Centers, markets, towers

**Imperial Age (Age 3):**
- **Max dimensions**: 50×40×25m
- **Max voxels**: 200,000
- **Examples**: Mega-structures, fortresses, monuments

**Wonders (Any Age):**
- **Max dimensions**: 100×100×50m
- **Max voxels**: 1,000,000
- **Examples**: Massive alliance projects, season-end goals

---

## Repair System

### Damage Recovery

**Repair Process:**
1. **Building takes damage** (combat, fire, collapse)
2. **HP reduces**, visual damage shows (cracks, holes)
3. **Commander orders repair** or peasants auto-repair
4. **Peasants gather repair materials** (same as original)
5. **Peasants repair damaged sections** (voxels regenerate)

**Repair Cost:**
```
Cost = (max_HP - current_HP) / 20 in materials

Example:
- Building has 10,000 max HP
- Currently at 3,000 HP
- Repair cost = (10,000 - 3,000) / 20 = 350 materials
```

**Repair Speed:**
- **Primitive peasants**: 5 voxels/second (half build speed)
- **Commander**: 10 voxels/second (half build speed)
- **Multiple workers**: Same diminishing returns as building

**Material Matching:**
- **Must repair with same material** (stone wall needs stone)
- **Mixed material buildings**: Need exact mix (more complex)
- **Standard designs**: Accept generic resources (simplified)

---

## Future Expansion Ideas

**Blueprint Marketplace:**
- **Trade/sell designs** (community blueprints)
- **Featured blueprints** (official gallery)
- **Seasonal contests** (best builds win prestige)

**Collaborative Blueprints:**
- **Alliance projects** (multiple players design together)
- **Mega-structures** (too large for one person)
- **Shared ownership** (all contributors get credit)

**Dynamic Materials:**
- **Crystals that glow** (lighting effects)
- **Living wood** (grows over time)
- **Magic materials** (special properties)

**Mechanical Components:**
- **Gates** (open/close)
- **Drawbridges** (raise/lower)
- **Traps** (activate on trigger)

**Interior Design:**
- **Functional rooms** (barracks bunks, throne room)
- **Bonuses** (well-designed interior = morale boost)
- **Aesthetic customization** (furniture, decorations)

---

*Build your civilization's identity, one voxel at a time. From foundation to fortress, every building tells a story.*
