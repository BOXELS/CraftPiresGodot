# Terrain & World Structure

## Overview

CraftPires features organic voxel-based terrain with full destructibility, underground layers, and realistic physics. The world is divided into shards (separate game instances) that players can travel between.

---

## Biomes (prototype direction — 2026-07-13)

**Default starter biome: Grasslands** (what the web shard generates today):
grass + dirt banks, sand shores, stone, fruit trees + conifers, fresh water,
and salt/ocean where a Grasslands edge meets an Ocean biome.

Each biome is a **data pack** (same spirit as civ packs):

| Field | Role |
| --- | --- |
| Surface palette | grass / sand / snow / ash… |
| Tree table | variants, min/max height, trunk width, wood/food yield, **sapling drop chance** |
| Mineral table | ore kinds (coal, copper, gold, diamond…) + **depth bands from bedrock** |
| Water table | decorative lakes + rare **Water Source** veins (type + volume) — see `physics-creativity.md` P3 |
| Fauna / climate | later |

**Saplings & growth:** harvesting trees rolls **1–3 saplings** from wood volume
(per-variant min/max in `TREE_SAPLING_RANGE`; always ≥1). Saplings drop as
ground piles with the tree’s `treeVariant` and haul into settlement stock.
**Planting + Minecraft-style growth** (min/max height → tree farms) is the next
wood pass. Rare **Redwood** biome later: extreme max height + wide base width.

**Oceans / rivers:** prefer driven by Water Source volume + cellular flow, not
only a flat decorative plane — once P3 ships.

---

## World Architecture

### Shard System

**What is a Shard?**
- **Separate game instance**: Each shard is its own 512×512×256m world
- **Named worlds**: "Shard Alpha", "Shard Beta", "Shard Genesis", etc.
- **50 civilizations per shard**: Maximum capacity to prevent lag
- **500+ players potential**: If each civ has 10 humans (1 Commander + 9 peasants)
- **Cross-shard travel**: Players can move between shards

**Why Multiple Shards?**
- **Performance**: Single world can't handle 1,000+ players without lag
- **Choice**: Players choose which shard to join
- **Different biomes**: Ice shard, desert shard, volcanic shard, forest shard
- **Unique politics**: Each shard develops its own alliances, wars, stories
- **Cross-shard warfare**: Travel between shards to help allies

**Starting Configuration:**
- **Launch**: One shard (Shard Alpha)
- **Expansion**: New shards added as funding/demand requires
- **No daily expansion**: Shards don't grow daily, new shards created when needed
- **Year-long seasons**: Each shard runs for 365 days

### Shard Dimensions

**Per Shard:**
- **Width**: 512 meters (X-axis)
- **Length**: 512 meters (Z-axis)
- **Height**: 256 meters (Y-axis)
- **Total volume**: 67,108,864 cubic meters
- **Walking distance**: ~7-10 minutes across (diagonal)

**Voxel Scale:**
- **Render voxels**: 0.1m³ (fine detail)
- **Simulation chunks**: 32×32×32 voxels (10.24m³ per chunk)
- **Total chunks per shard**: 16×16×8 = 2,048 chunks
- **Voxels per shard**: ~67 billion potential voxels

### Cross-Shard Travel

**How It Works:**
1. **Player approaches shard boundary** (edge of 512×512m world)
2. **Portal/gateway appears** (physical structure or UI prompt)
3. **Player selects destination shard** from list
4. **Loading screen** (5-10 seconds)
5. **Player spawns** at corresponding location in new shard

**Example:**
- Player at coordinates (500, 50, 250) in Shard Alpha
- Travels to Shard Beta
- Spawns at coordinates (12, 50, 250) in Shard Beta (near edge)

**Strategic Uses:**
- **Escape enemies**: Jump to different shard when overwhelmed
- **Help allies**: Travel to ally's shard to support in battle
- **Resource gathering**: Find rare materials in different biomes
- **Start fresh**: Abandon losing shard, begin anew elsewhere

---

## Voxel Terrain System

### Organic Visual Style

**NOT Minecraft Blocky:**
- **Randomized edges**: Voxels have irregular, natural shapes
- **Smooth transitions**: Terrain blends between materials
- **Jagged cliffs**: Realistic rock formations
- **Rough caves**: Organic underground spaces

**Render Layer (What Players See):**
- **Fine voxels**: 0.1m³ scale for visual detail
- **Procedural variation**: Each voxel slightly different
- **Natural appearance**: Mountains, valleys, rivers look real
- **Destruction leaves scars**: Mining creates rough craters, not perfect holes

**Simulation Layer (How Game Calculates):**
- **Chunk-based**: 32×32×32 voxels per chunk (invisible to players)
- **Efficient processing**: Game only calculates changed chunks
- **LOD (Level of Detail)**: Distant chunks use simplified meshes
- **Greedy meshing**: Combines adjacent voxels into optimized polygons

### Material Types & Distribution

**Common Materials (80-100 per chunk):**
- **Wood**: Forests, surface layer
- **Stone**: Mountains, underground
- **Dirt**: Surface layer, hills
- **Food sources**: Berries, fish, animals

**Uncommon Materials (20-30 per chunk):**
- **Clay**: Near water, river banks
- **Iron**: Underground, 20-60m depth
- **Coal**: Underground, 10-50m depth
- **Sand**: Deserts, beaches

**Rare Materials (5-10 per chunk):**
- **Gold**: Deep underground, 50-100m depth
- **Obsidian**: Volcanic regions, lava-water contact
- **Emerald**: Very deep, 80-150m depth

**Very Rare Materials (1-3 per chunk):**
- **Diamond**: Extremely deep, 100-200m depth
- **Sapphire**: Rare gem nodes
- **Ruby**: Rare gem nodes

### Terrain Generation

**Biome Types per Shard:**
- **Temperate Forest**: Balanced resources, wood abundant
- **Desert**: Sand abundant, water scarce, hidden oases
- **Mountains**: Stone abundant, iron/coal rich, difficult terrain
- **Plains**: Flat, easy building, food abundant
- **Volcanic**: Obsidian abundant, lava hazards, fire-resistant materials
- **Tundra**: Ice/snow, emerald deposits, cold hazards
- **Swamp**: Clay abundant, mud hazards, water everywhere

**Procedural Generation:**
- **Noise algorithms**: Perlin/Simplex noise for terrain height
- **Biome blending**: Smooth transitions between biomes
- **Resource veins**: Ore deposits follow logical patterns (deeper = rarer)
- **Water tables**: Underground water at varying depths
- **Cave systems**: Natural underground networks

---

## Underground Layer

### Depth Zones

**Surface (0-10m):**
- **Easy access**: Commander beam mining, peasant digging
- **Common materials**: Dirt, clay, stone, wood roots
- **No hazards**: Safe to excavate
- **No supports needed**: Shallow tunnels stable

**Shallow Underground (10-50m):**
- **Moderate access**: Requires iron tools
- **Uncommon materials**: Iron, coal, clay deposits
- **Minor hazards**: Cave-ins if no supports
- **Wood supports required**: Every 8m

**Deep Underground (50-100m):**
- **Difficult access**: Requires steel tools
- **Rare materials**: Gold, obsidian, large ore veins
- **Major hazards**: Water tables, lava pockets, cave-ins
- **Stone supports required**: Every 12m

**Very Deep Underground (100-200m):**
- **Extreme access**: Requires diamond tools
- **Very rare materials**: Diamond, emerald, sapphire, ruby
- **Extreme hazards**: Lava lakes, high-pressure water, unstable terrain
- **Iron supports required**: Every 20m

**Bedrock (200-256m):**
- **Indestructible layer**: Can't mine through
- **Bottom of world**: No resources below
- **Strategic limit**: Can't dig infinitely deep

### Underground Construction

**Tunnel Networks:**
- **Carved from terrain**: Not placed voxels, excavated space
- **Support beams required**: Wood, stone, or iron pillars
- **Spacing rules**:
  - Wood beams: Every 8m
  - Stone pillars: Every 12m
  - Iron pillars: Every 20m

**Cave Systems:**
- **Natural caves**: Pre-generated during world creation
- **Artificial tunnels**: Player-excavated passages
- **Connected networks**: Can link natural and artificial
- **Strategic value**: Hidden routes, surprise attacks

**Underground Bases:**
- **Excavation process**:
  1. Dig out large chamber (Commander beam or peasants)
  2. Install support pillars at intervals
  3. Build structures inside chamber (voxel construction)
  4. Create entrance tunnels with supports
- **Ceiling height limits**:
  - Wood supports: 5m max ceiling
  - Stone supports: 10m max ceiling
  - Iron supports: 15m max ceiling

**Collapse Mechanics:**
- **Remove supports**: If >30% removed, gradual collapse (5-minute warning)
- **Explosive damage**: Instant collapse if supports destroyed
- **Weight from above**: Heavy structures above can trigger collapse
- **Water breach**: Hitting water table can flood and collapse

---

## Water Physics

### Water Behavior

**Flow Simulation:**
- **Cellular automata**: Water flows based on neighbor voxels
- **Downward priority**: Water flows down first
- **Sideways spread**: Water spreads horizontally if can't flow down
- **Pressure**: Water at depth has higher pressure (flows faster)

**Water Levels:**
- **8 levels per voxel**: From empty (0) to full (8)
- **Gradual filling**: Water accumulates over time
- **Evaporation**: Water slowly disappears in hot biomes
- **Freezing**: Water becomes ice in cold biomes

**Water Sources:**
- **Rivers**: Surface water flowing from high to low
- **Lakes**: Natural water pools
- **Oceans**: Large bodies of water (shard edges)
- **Underground water tables**: Deep water reserves (50-150m depth)
- **Rain**: Temporary water generation (weather events)

### Strategic Water Use

**Irrigation:**
- **Canal systems**: Dig trenches to direct water to farms
- **Water wheels**: Faster farming when powered by water flow
- **Reservoir**: Store water for droughts

**Moats:**
- **Defensive**: Dig moats around towns (water-filled trenches)
- **Drowning traps**: Enemies fall in, drown
- **Bridge control**: Build bridges, destroy to isolate enemies

**Flooding:**
- **Offensive weapon**: Dam rivers, redirect to enemy territory
- **Underground flooding**: Breach water table into enemy tunnels
- **Terrain modification**: Permanently flood areas to deny access

**Mud Creation:**
- **Water + Dirt = Mud**: Mix creates sticky, slow terrain
- **Movement penalty**: Units move 50% slower in mud
- **Trap potential**: Enemies get stuck, easier to attack
- **Temporary**: Mud dries over time (becomes dirt)

---

## Fire Physics

### Fire Spread

**Combustion Rules:**
- **Flammable materials**: Wood, wool, leaves, thatch
- **Ignition sources**: Torches, coal fires, enemy fire arrows, lava
- **Spread chance**: 10% per adjacent flammable voxel per second
- **Burn time**: Flammable voxels burn for 30-60 seconds then turn to ash (air)

**Fire Resistance:**
- **Stone**: 10% fire resistance (harder to ignite)
- **Clay**: 15% fire resistance
- **Obsidian**: 40% fire resistance (very hard to ignite)
- **Iron**: 20% fire resistance
- **Wood**: -20% fire resistance (easier to ignite)

**Strategic Fire Use:**
- **Siege weapon**: Fire arrows ignite wooden structures
- **Area denial**: Burn forests to deny enemy resources
- **Traps**: Create fire traps in tunnels
- **Scorched earth**: Burn everything when retreating

**Fire Hazards:**
- **Uncontrolled spread**: Fire can spread to your own structures
- **Peasant death**: Peasants caught in fire die
- **Material loss**: Burned structures drop 0% materials (total loss)
- **Permanent scars**: Burned areas show as ash/charred terrain

---

## Gravity & Collapse

### Gravity-Affected Materials

**Falling Voxels:**
- **Dirt**: Falls if unsupported
- **Sand**: Falls if unsupported
- **Gravel**: Falls if unsupported
- **Snow**: Falls if unsupported

**Stable Materials:**
- **Stone**: Doesn't fall (stays in place)
- **Wood**: Doesn't fall (stays in place)
- **Iron**: Doesn't fall (stays in place)
- **Ore**: Doesn't fall (stays in place)

### Collapse Mechanics

**Unsupported Structures:**
- **Check support**: Game checks if structure has foundation/supports
- **Foundation required**: Heavy materials need strong base
- **Weight calculation**: Sum of all voxels above
- **Collapse if exceeded**: Structure falls if weight > support strength

**Example Collapses:**
- **Diamond tower on dirt**: Collapses (dirt too weak)
- **Stone bridge with no pillars**: Collapses (no support)
- **Underground without supports**: Cave-in (no beams/pillars)
- **Too much weight above tunnel**: Tunnel collapses

**Collapse Damage:**
- **Falling voxels**: Deal damage to units below (crushing)
- **Destruction**: Collapsed structures become rubble
- **Material recovery**: 10-30% of materials recoverable from rubble
- **Permanent scar**: Collapsed area shows as crater/rubble pile

---

## Terrain Modification & Warfare

### Strategic Terrain Changes

**Offensive Modifications:**
- **Dig moats**: Create trenches around enemy bases (water-filled or dry)
- **Collapse tunnels**: Destroy enemy underground bases
- **Dam rivers**: Cut off enemy water supply
- **Flood valleys**: Submerge enemy lowland bases
- **Create mud**: Make enemy territory difficult to traverse

**Defensive Modifications:**
- **Build walls**: Fortify borders with stone/iron walls
- **Raise berms**: Create elevated defensive positions
- **Dig trenches**: Slow enemy advances
- **Create choke points**: Funnel enemies into kill zones
- **Trap placement**: Pitfalls, mud traps, fire traps

**Economic Modifications:**
- **Flatten land**: Create efficient building platforms
- **Terrace farms**: Create flat farming terraces on slopes
- **Clear forests**: Open land for expansion
- **Quarries**: Dedicated stone mining pits
- **Canal systems**: Irrigation for farms

### Permanent World Scars

**After One Year:**
- **Every mine**: Visible crater or pit
- **Every battle**: Destroyed structures leave ruins
- **Every tunnel**: Underground networks persist
- **Every river diversion**: Permanent landscape change
- **Every flood**: Low areas filled with sediment

**Hall of Legends:**
- **Screenshot archives**: Before/after comparisons
- **Historical landmarks**: Famous battle sites preserved
- **Mega-structures**: Wonders and monuments documented
- **Civilization legacies**: Greatest builds immortalized

---

## Biome-Specific Features

### Temperate Forest

**Resources:**
- **Wood**: Abundant (80-100 per chunk)
- **Food**: Berries, deer, fish
- **Stone**: Moderate (30-50 per chunk)
- **Iron/Coal**: Moderate underground

**Terrain:**
- **Rolling hills**: Easy to build, moderate defensibility
- **Rivers**: Fresh water sources
- **Caves**: Natural underground networks
- **Clearings**: Open areas for towns

### Desert

**Resources:**
- **Sand**: Abundant (90-100 per chunk)
- **Stone**: Scarce (10-20 per chunk)
- **Water**: Very scarce (hidden oases)
- **Gold**: Abundant underground (2× normal spawn rate)

**Terrain:**
- **Dunes**: Shifting sand, difficult building
- **Canyons**: Deep ravines, strategic choke points
- **Oases**: Rare water sources, contested territory
- **Flat expanses**: Easy visibility, hard to hide

**Hazards:**
- **Heat**: Peasants work slower (-10% speed)
- **Sandstorms**: Visibility reduced, units lost
- **Water scarcity**: Must import or find oases

### Mountains

**Resources:**
- **Stone**: Abundant (80-100 per chunk)
- **Iron**: Abundant underground (2× spawn rate)
- **Coal**: Abundant underground (2× spawn rate)
- **Wood**: Scarce (10-20 per chunk)

**Terrain:**
- **Steep slopes**: Difficult building, excellent defense
- **Caves**: Extensive underground systems
- **Peaks**: High vantage points, towers
- **Valleys**: Sheltered areas, limited access

**Strategic Value:**
- **High ground**: +10% combat bonus
- **Natural fortifications**: Mountains as walls
- **Resource rich**: Iron/coal/stone abundant
- **Difficult access**: Easy to defend

### Volcanic

**Resources:**
- **Obsidian**: Abundant (30-50 per chunk)
- **Lava**: Abundant (hazard and resource)
- **Iron**: Abundant underground
- **Coal**: Abundant underground

**Terrain:**
- **Lava flows**: Active hazards
- **Ash fields**: Gray landscape, poor farming
- **Volcanic vents**: Lava sources
- **Rocky ground**: Difficult excavation

**Strategic Features:**
- **Fire immunity**: Obsidian structures resist fire
- **Lava moats**: Natural defenses
- **Hostile environment**: Deters invaders
- **Unique materials**: Obsidian only found here

---

## Weather & Environmental Hazards

### Weather Events

**Rain:**
- **Effect**: Creates temporary water voxels
- **Duration**: 5-15 minutes
- **Frequency**: Random (1-2× per day)
- **Impact**: Floods low areas, creates mud

**Snow:**
- **Effect**: Snow accumulates on surfaces
- **Duration**: Seasonal (winter months)
- **Impact**: Slows movement, weight on roofs (collapse risk)

**Sandstorms (Desert):**
- **Effect**: Reduces visibility to 10m
- **Duration**: 10-30 minutes
- **Impact**: Units get lost, combat difficult

**Volcanic Eruptions (Volcanic):**
- **Effect**: Lava flows from vents
- **Duration**: 30-60 minutes
- **Impact**: Destroys everything in path

### Hazards

**Lava:**
- **Damage**: 50 HP/second (instant death for most units)
- **Fire ignition**: Ignites adjacent flammable materials
- **Obsidian creation**: Lava + water = obsidian

**Quicksand/Mud:**
- **Movement penalty**: 50-75% slower
- **Trap potential**: Units can get stuck
- **Escape**: Requires help from allies

**Cave-ins:**
- **Damage**: Crushing damage (200 HP)
- **Burial**: Units trapped under rubble
- **Rescue**: Peasants must dig out survivors

---

## Performance Optimization

### Chunk Loading

**View Distance:**
- **Default**: 256m (8 chunks radius)
- **High settings**: 512m (16 chunks radius)
- **Low settings**: 128m (4 chunks radius)

**Loading Strategy:**
- **Spiral pattern**: Load chunks in spiral from player position
- **Priority queue**: Closer chunks load first
- **Unload distant**: Unload chunks beyond view distance + buffer
- **Aggressive caching**: Keep recently-visited chunks in memory

### LOD (Level of Detail)

**Distance Bands:**
- **0-64m**: Full detail (all voxels rendered)
- **64-128m**: Medium detail (greedy meshing)
- **128-256m**: Low detail (simplified meshes)
- **256m+**: Very low detail (single cube per chunk)

### Mesh Optimization

**Greedy Meshing:**
- **Combines adjacent voxels**: Single quad instead of multiple cubes
- **10-100× reduction**: Millions of voxels → thousands of triangles
- **Real-time updates**: Re-mesh only changed chunks

---

*A living, breathing world. Every scar tells a story. Every mountain holds secrets. Every war reshapes the land forever.*
