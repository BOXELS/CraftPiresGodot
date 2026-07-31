# Core Concepts

## 🎯 Core Goal: No Excuse for Boredom

**The design philosophy = Every session offers 1000 ways to play.**
- **Build it, break it, rebuild it.**
- **Test out insane physics contraptions.**
- **Laugh** when your mud trap backfires and floods your own peasants.
- Try a dirt-throwing trebuchet army one game, then a diamond fortress the next.
- This keeps players engaged not just for hours, but across days/weeks/months in a persistent world.

### The Pillars of "Infinite Fun"

**1. Endless Building**
- **Every voxel is usable**: dirt, stone, coal, emerald, even mud.
- **Structures don't vanish** when destroyed — they crumble into resources you can scoop back up.
- **Player-built towns look unique** every time because they're literally made from what you mine.

**2. Chaotic Creativity**
- **Water + dirt = mud** (slows units, creates sinkholes).
- **Lava + water = obsidian traps.**
- **Sand + wood = quick flammable defenses** (or disasters).
- **Physics contraptions**: wind tunnels to slow armies, water wheels to speed up mining, gravity drops that crush invaders with boulders.

**3. Persistent Warfare**
- **The battlefield remembers everything.** Dig a trench, dam a river, collapse a tunnel — it's still there tomorrow.
- **Enemies don't just "attack"**; they reshape the map.
- **Losing isn't the end** — you can respawn, rebuild, and plot revenge.

**4. Laugh Factor**
- **Dirt trebuchets** splattering across enemy walls.
- **Peasant-flingers** (with a slim chance the poor guy survives).
- An enemy accidentally drowning his army when his mud trap collapses too early.
- Emerald "bling" fortresses that shine like a Vegas casino — and crumble hilariously under a stone avalanche.

**5. Real-World Value**
- **Cryptocurrency rewards** for in-game achievements
- **NFT rare items** that players can war over and capture
- **Epic storylines** around valuable items worth real money
- **High-stakes battles** where every victory has real consequences

**⚖️ Key Design Balance**
- **Resource trade-offs**: Mud traps are cheap but temporary, diamonds are strong but scarce.
- **Physics fairness**: Systems should be emergent but predictable enough that players can plan.
- **Creative loss isn't wasted**: Even when destroyed, players gain a story, resources, or a funny failure.

**🌀 Long-Term Vision**
CraftPires becomes a "forever game" because every season feels like:
- **Minecraft's creativity,**
- **Age of Empires' empire wars,**
- **Total Annihilation's epic commanders,**
- **Dwarf Fortress's emergent hilarity.**
And after a year-long shard ends, the Hall of Legends preserves the insane scars, castles, mud pits, diamond fortresses, and stories of revenge.

**✅ In short**: You're not designing a game — you're designing a toybox of war and wonder, where players never run out of things to test, build, or laugh at.

---

## The Big Ideas

### 1. Organic Voxel-Based Terrain

- **Visual Style**: Fine randomized voxels create organic, natural-looking terrain (NOT blocky Minecraft cubes)
- **Render Layer**: Tiny voxels (~0.1m³) with randomized edges—jagged cliffs, rough caves, natural shapes
- **Simulation Layer**: Grouped into efficient chunks (32×32×32 voxels) for performance (invisible to players)
- **Full Destructibility**: Mining creates rough craters and scars, not perfect grid holes
- **Persistence**: Every scar, crater, and structure tells the season's story

### 2. Peasant System (Like Age of Empires II)

**The Foundation of Everything:**
- **Unlimited peasants** based on housing capacity and food resources
- **Multi-role workers**: Miners, builders, farmers, lumberjacks, soldiers
- **Progression stages**: Primitive (wooden tools) → Advanced (diamond tools, hovercrafts)
- **Commander controls all AI peasants** (like AoE II villagers)

**Co-Op Multiplayer:**
- **Up to 10 humans per civilization**: 1 Commander + 9 human-controlled peasants
- **Human peasants** control ONE peasant character each
- **AI peasants** (unlimited) controlled by Commander
- **Voice chat coordination** for real-time teamwork

**Peasant Evolution:**
- **Stage 1 (Primitive)**: Walking, weak, vulnerable, basic wooden tools
- **Stage 2 (Road-Building)**: Iron tools, can build roads, moderate strength
- **Stage 3 (Wheel-Discovering)**: Steel tools, carts, much stronger
- **Stage 4 (Advanced)**: Diamond tools, hovercrafts, elite capabilities

### 3. Commander System (Like Total Annihilation)

**Your Civilization's Leader:**
- **Strategic control** of all AI peasants
- **Beam mining** (2× gathering speed, Dune-style laser extraction)
- **Can die** but respawns with resource cost
- **Command aura** (+10% morale/work rate to nearby units)
- **Material mastery upgrades** (Iron, Diamond, Emerald, Obsidian)

**Respawn System:**
- **Cost**: Variable resources + time (peasants rebuild Commander)
- **Unlimited respawns** (no maximum limit)
- **Enemy capture**: Enemies can steal Commander voxels and rebuild as sub-commander
- **Strategic vulnerability**: Killing enemy Commander cripples their civ

### 4. Resources Are the Battlefield

**Everything is physical**:
- Buildings are made of actual voxel blocks
- Destroying structures drops materials (60-70% recovery rate)
- Siege weapons throw real resources as projectiles
- Enemy cities are the richest resource nodes

### 5. Wars Reshape Terrain Permanently

**Strategic terrain modification**:
- Dig moats around towns
- Collapse tunnels under enemy walls
- Redirect rivers to flood farmland
- Hollow out mountains for fortress cores
- Create berms and defensive earthworks

**After one year**: The map becomes a scarred historical artifact showing every civilization's rise and fall

### 6. Multi-Shard World Structure

**World Architecture:**
- **Start**: One shard (512×512×256m world)
- **Expansion**: New shards added as funding/demand requires
- **Each shard**: Separate game instance with unique name ("Shard Alpha", "Shard Beta")
- **Cross-shard travel**: Players can move between shards
- **50 civilizations per shard** (500+ potential players if each civ has 10 humans)

**Why Multiple Shards:**
- **Performance**: Prevent single shard from lagging with too many players
- **Choice**: Players choose which shard to start on
- **Cross-shard warfare**: Travel between shards to help allies or attack enemies
- **Unique identities**: Each shard develops its own politics, alliances, stories

---

## Player Experience

### The Team Experience

**Commander Role:**
- **Strategic control** (build orders, diplomacy, resource allocation)
- **Beam mining** (2× speed, signature ability)
- **High stakes** (expensive respawn, civilization leader)
- **Leadership** (coordinate team, make decisions)
- **Stream spotlight** (fame potential)

**Peasant Role (Human-Controlled):**
- **Specialized tasks** (mining, building, combat, scouting)
- **Team coordination** (voice chat, tactics)
- **Skill progression** (become expert in your role)
- **Social gaming** (friends working together)
- **Control ONE peasant character** (not multiple units)

**AI Peasants (Commander-Controlled):**
- **Unlimited quantity** (based on housing capacity)
- **Basic tasks** (gathering, construction, military)
- **AoE II-style control** (select, assign, hotkeys)
- **Auto-task finding** (idle peasants find work)

### The Revenge Cycle

1. Team builds a civilization over weeks
2. Gets destroyed by a rival alliance
3. Can respawn and rebuild with 24/7 AI automation
4. Joins or forms alliance to seek revenge
5. **Cross-shard warfare** - allies from other shards join the fight
6. Cycle continues throughout the year-long season

### The Forever Game

- No match ends until shard reset (yearly)
- 24/7 AI automation (no offline shields)
- Optional newbie immunity (at distance from other players)
- Progress persists, world evolves
- Offline settings keep your civ moving

### Emergent Identity

Your civilization's identity emerges from:
- **Resources gathered** - Diamond kingdom vs dirt horde
- **Building style** - Custom voxel builds vs efficient construction
- **Terrain shaping** - Underground bases vs sky fortresses
- **War tactics** - Siege masters vs guerilla tunnelers
- **Team coordination** - Solo vs coordinated team play
- **Alliances** - Trade federation vs conquest empire
- **Power level** - Primitive vs Advanced vs Mega civilization
- **Rare items** - Legendary weapons, ancient artifacts, territory deeds

### Power Imbalance & Opportunity

**Not All Civilizations Are Equal:**
- **New players** - Vulnerable, learning, building first base
- **Established civs** - Weeks of progress, strong defenses
- **Mega civs** - Months of development, alliance leaders

**No Immunity Shields (Except Optional Newbie):**
- **24/7 gameplay** - World never stops
- **AI automation** - Offline settings keep civ running
- **Comeback potential** - Rebuild from ruins, seek revenge
- **Cross-shard help** - Call allies from other shards

**Hilarious Trolling:**
- **Peasant cannon** - Launch peasants as trebuchet ammunition
- **Peasant physics** - They fly through the air screaming
- **Survival chance** - Low but possible
- **Sabotage potential** - Surviving peasants become saboteurs

### Customization Sandbox

**Creative Expression:**
- **Aesthetic customization** - Dye wool, create unique colors
- **Building decoration** - Black wool around diamond structures
- **Civilization identity** - Gothic dark civs, crystal palaces
- **Physics experimentation** - Mud traps, water wheels, gravity drops

**Realistic Consequences:**
- **Physical material delivery** - Peasants must carry materials (Settlers-style)
- **Fire hazards** - Black wool is highly flammable
- **Disaster scenarios** - Entire civilizations can burn down
- **Recovery stories** - Rebuilding after epic failures

### Tech Progression System (Empire Earth-Inspired)

**Three Distinct Ages:**
- **Age 1 (Primitive)** - Basic survival, wood/stone tools, militia
- **Age 2 (Metal)** - Iron weapons, siege warfare, economic development
- **Age 3 (Gunpowder/Crystal)** - Explosive power, diplomacy, advanced infrastructure

**Resource-Driven Progression:**
- Mining unlocks technologies directly
- Branching choices (military, economic, diplomatic)
- Commander upgrades tied to materials (Iron Mastery, Diamond Mastery)
- No civilization can unlock everything

---

## Scale & Scope

### Per Shard (512×512×256m world)

- **Up to 50 civilizations** maximum
- **50 to 500+ total humans** (if each civ has 1-10 players)
- **Thousands of AI peasants** (unlimited per civ, housing-limited)
- **Seamless terrain** (no loading screens within shard)
- **24/7 gameplay** (AI automation when players offline)

### Multiple Shards (Linked Worlds)

- **Separate game instances** (reduce server load)
- **Named shards**: "Shard Alpha", "Shard Beta", "Shard Genesis"
- **Cross-shard travel**: Load into different shards to help allies
- **Shared reputation**: Prestige, achievements carry across shards
- **Different biomes**: Ice world, desert world, volcanic world, forest world

### Year-Long Seasons

- **365-day cycle** per shard
- **Persistent world**: All changes permanent until season end
- **Hall of Legends**: Best civs immortalized
- **Season reset**: New shard begins, old world becomes "artifact"

---

## Design Pillars

1. **Tactile Resource Management** - You feel every block mined and placed
2. **Meaningful Destruction** - War has permanent consequences
3. **Creative Expression** - Build your vision with gathered resources
4. **Strategic Depth** - Terrain, materials, and timing all matter
5. **Living History** - The world remembers everything
6. **Team Coordination** - Success requires human cooperation
7. **Community Drama** - Live-streamed stories create lasting memories
8. **Physics Creativity** - Experiment with water, mud, gravity, fire

---

## Anti-Patterns to Avoid

- ❌ Abstract resources that don't feel real
- ❌ Instant building/destruction with no physicality
- ❌ Static terrain that never changes
- ❌ Pay-to-win mechanics
- ❌ Griefing without counterplay
- ❌ Loss of all progress on death
- ❌ Solo-only gameplay (missing team dynamics)
- ❌ Isolated shards (missing cross-shard warfare)
- ❌ Prefab building assets (everything is voxel-based)

---

## What Makes It Work

✅ **Resources have weight** - They exist, can be moved, stolen, thrown  
✅ **Commander has personality** - Not just a cursor, but your avatar  
✅ **Terrain tells stories** - Scars show history  
✅ **Time creates drama** - Year-long world builds real stakes  
✅ **Creativity meets strategy** - Minecraft freedom + RTS tactics  
✅ **Team coordination** - Human cooperation creates emergent gameplay  
✅ **Unlimited peasants** - Economic depth like AoE II  
✅ **Physical hauling** - Settlers-style satisfaction  
✅ **Cross-shard warfare** - Epic scale beyond single world  
✅ **No prefabs** - Everything built from gathered voxels

---

## Game Modes

### 1. Solo Commander (1 player)
- 1 Commander controls unlimited AI peasants
- **Personal empire** building
- **Skill-based** (no team coordination needed)
- **Good for**: New players, practice, focused strategy

### 2. Co-Op Team (2-10 players per civ)
- 1 Commander + 1-9 human peasants + unlimited AI peasants
- **Team coordination** required
- **Role specialization** (miner, builder, warrior, scout)
- **Good for**: Friends, social gaming, complex tactics

### 3. Solo vs Solo (1v1 civs)
- 2 Commanders, each with unlimited AI peasants
- **Intimate battles**, personal drama
- **Strategic depth** (micro/macro management)
- **Good for**: Competitive play, tournaments

### 4. Team vs Team (Multiple civs)
- Multiple civilizations per shard (up to 50)
- **Alliance warfare**, political complexity
- **Cross-shard support** (call allies from other shards)
- **Good for**: Epic battles, long-term rivalry

---

## Building System (Settlers II-Inspired)

### Physical Material Delivery

**No Prefabs - Everything is Voxel Construction:**
- **Peasants physically carry** materials from storage to construction sites
- **Visible transport** - Watch voxel clumps being moved
- **Construction phases** - Foundation → Walls → Roof → Complete
- **Material requirements** - Bill of materials calculated from voxel design
- **Tool requirements** - Peasants need appropriate tools per phase

**Construction Process:**
1. Commander places building foundation (marks location)
2. Game calculates required materials (wood, stone, etc.)
3. Peasants gather materials from storage depots
4. Peasants carry materials to construction site
5. Peasants build in stages (25%, 50%, 75%, 100%)
6. Building becomes functional when 100% complete

**The Settlers Experience:**
- **Supply chains** - Materials flow from mines → storage → construction
- **Logistics planning** - Efficient transport routes reduce build time
- **Resource management** - Balance gathering vs construction
- **Peasant coordination** - Multiple workers needed for large projects
- **Satisfying visuals** - Watch your civilization grow

---

*One world, growing across shards. Teams of heroes, building legends. Physics-driven chaos. Voxel-powered warfare.*
