# Peasant System

## Overview

Peasants are the backbone of CraftPires civilizations. Inspired by Age of Empires II villagers and The Settlers II workers, they gather resources, construct buildings, and form the foundation of your economy and military. **Unlike AoE II disposable villagers, CraftPires peasants level up with experience, making them valuable individuals worth protecting.**

---

## Peasant Types

### AI Peasants (Unlimited, Commander-Controlled)

**What They Are:**
- **Worker units** like AoE II villagers
- **Unlimited quantity** based on housing capacity
- **Commander controls all** (select, assign, hotkeys)
- **Level up with experience** (become valuable assets - NOT DISPOSABLE like AoE II)
- **Auto-task finding** (idle peasants find work automatically)
- **Individual progression** (each peasant gains XP and levels independently)

**Core Roles:**
- **Miners** - Extract wood, stone, iron, gold, diamonds
- **Builders** - Construct buildings, carry materials
- **Farmers** - Grow food, harvest crops
- **Lumberjacks** - Chop wood, gather logs
- **Soldiers** - Train into military units (militia, infantry, knights)
- **Engineers** - Operate siege weapons, build defenses
- **Scouts** - Explore, gather intelligence
- **Diplomats** - Negotiate alliances, trade

**Control Methods:**
- **Hotkeys** (like AoE II): Select all idle peasants, go to nearest resource
- **Click selection**: Drag-select multiple peasants, assign tasks
- **Building queues**: Queue peasants to be trained from Town Center
- **Auto-assignment**: Idle peasants automatically find nearby tasks (can be disabled)
- **Vocation management**: Assign peasants to specific roles permanently (locks in specialization)
- **Level tracking**: UI shows peasant level badges (visual indicators of expertise)

### Human-Controlled Peasants (0-9, Optional Co-Op)

**What They Are:**
- **Player characters** - Each human controls ONE peasant
- **Maximum 9 per civ** (plus 1 Commander = 10 humans total)
- **Full control** - Movement, actions, inventory, combat
- **Level up like FPS/RPG** - Gain XP, unlock abilities, become elite
- **Role specialization** - Master your chosen vocation

**Player Experience:**
- **First-person OR third-person** perspective (player choice)
- **Direct control** - WASD movement, mouse interaction
- **Inventory system** - Carry materials, tools, weapons
- **Progression system** - Level 1-100 with unlockable abilities
- **FPS-style gameplay** - Can play as elite warrior, master miner, etc.

**Example 10-Player Team:**
1. **Commander** (Player 1) - Strategic overview, beam mining, coordination
2. **Master Miner** (Player 2) - Level 80+ Miner, rare materials specialist
3. **Head Builder** (Player 3) - Level 75+ Builder, construction expert
4. **Military Captain** (Player 4) - Level 90+ Warrior, leads armies
5. **Scout** (Player 5) - Level 60+ Scout, intelligence gathering
6. **Master Farmer** (Player 6) - Level 85+ Farmer, food production
7. **Chief Engineer** (Player 7) - Level 70+ Engineer, siege weapons
8. **Diplomat** (Player 8) - Level 65+ Diplomat, alliance management
9. **Defender** (Player 9) - Level 75+ Warrior, defensive specialist
10. **Saboteur** (Player 10) - Level 80+ Scout, infiltration expert

---

## Peasant XP & Leveling System

### Vocation System

**Peasants choose vocations and level up (1-100):**

```typescript
enum Vocation {
  Miner,      // Resource extraction specialist
  Farmer,     // Food production specialist
  Builder,    // Construction specialist
  Warrior,    // Combat specialist
  Scout,      // Exploration & intelligence
  Diplomat,   // Alliance & trade specialist
  Engineer,   // Siege weapons & defenses
  Saboteur    // Infiltration & espionage
}

interface Peasant {
  id: string;
  name: string; // Randomly generated or player-named
  vocation: Vocation;
  level: number; // 1-100
  xp: number;
  stats: PeasantStats;
  skills: Skill[];
  age: number; // Time alive (days)
}
```

### Leveling Progression

**XP Required Per Level:**
```
Level 1 → 2: 100 XP
Level 10 → 11: 1,000 XP
Level 50 → 51: 25,000 XP
Level 99 → 100: 100,000 XP

Total to reach Level 100: ~2.5 million XP
Time to reach Level 100: Weeks to months of active use
```

**XP Gain Rates:**

| Action | XP Gained | Vocation |
|--------|-----------|----------|
| Mine wood | 1 XP | Miner |
| Mine stone | 2 XP | Miner |
| Mine iron | 5 XP | Miner |
| Mine gold | 10 XP | Miner |
| Mine diamond | 20 XP | Miner |
| Plant crop | 1 XP | Farmer |
| Harvest crop | 5 XP | Farmer |
| Full farm cycle | 10 XP | Farmer |
| Place voxel | 0.1 XP | Builder |
| Complete structure | 50 XP | Builder |
| Kill peasant | 10 XP | Warrior |
| Kill Commander | 100 XP | Warrior |
| Destroy structure | 25 XP | Warrior |
| Discover new area | 20 XP | Scout |
| Successful spy mission | 50 XP | Scout/Saboteur |
| Complete trade | 15 XP | Diplomat |
| Form alliance | 100 XP | Diplomat |
| Operate siege weapon | 5 XP | Engineer |
| Destroy structure (siege) | 30 XP | Engineer |

### Vocation-Specific Progression

#### Miner (Level 1 → 100)

**Level 1 (Rookie Miner):**
- Mining speed: 1.0× base
- Can mine: Wood, stone, dirt
- Find rare materials: 0% bonus
- Tool durability: 100% usage rate

**Level 25 (Apprentice Miner):**
- Mining speed: 1.5× base
- Can mine: Iron, coal, clay
- Find rare materials: +10% bonus
- Tool durability: 85% usage rate

**Level 50 (Journeyman Miner):**
- Mining speed: 2.0× base
- Can mine: Gold, emerald
- Find rare materials: +25% bonus
- Tool durability: 70% usage rate

**Level 75 (Expert Miner):**
- Mining speed: 2.5× base
- Can mine: Diamond, obsidian
- Find rare materials: +50% bonus
- Tool durability: 55% usage rate

**Level 100 (Master Miner):**
- Mining speed: 3.0× base (3× normal peasant!)
- Can mine: ANY material with maximum efficiency
- Find rare materials: +100% bonus (2× chance to find diamonds, emeralds)
- Tool durability: 50% usage rate (tools last 2× longer)
- Special ability: "Vein Sense" - Detect nearby rare ore veins

#### Farmer (Level 1 → 100)

**Level 1 (Peasant Farmer):**
- Crop yield: 100 food per cycle
- Growth time: 60 seconds
- Can plant: Basic crops only
- Weather resistance: 0%

**Level 50 (Agricultural Expert):**
- Crop yield: 200 food per cycle
- Growth time: 40 seconds
- Can plant: All crop types
- Weather resistance: 50%

**Level 100 (Master Farmer):**
- Crop yield: 300 food per cycle (3× normal!)
- Growth time: 20 seconds (instant harvest!)
- Can plant: Anywhere, even poor soil
- Weather resistance: 100% (never lose crops)
- Special ability: "Green Thumb" - Adjacent farms produce +50% yield

#### Warrior (Level 1 → 100)

**Level 1 (Militia):**
- HP: 50
- Damage: 10
- Armor: 0
- Attack speed: 1.0×
- Can use: Wooden spear

**Level 50 (Knight):**
- HP: 150
- Damage: 40
- Armor: 5
- Attack speed: 1.2×
- Can use: Iron sword, bow, shield
- Special ability: "Battle Cry" - +20% damage to nearby allies (10s duration)

**Level 100 (Elite Champion):**
- HP: 300 (6× base peasant!)
- Damage: 80 (16× base peasant!)
- Armor: 15
- Attack speed: 1.5×
- Can use: Diamond sword, longbow, full plate armor
- Special abilities: "Charge" (dash attack), "Parry" (deflect attacks), "Execute" (finish wounded enemies)

#### Builder (Level 1 → 100)

**Level 1 (Apprentice Builder):**
- Build speed: 10 voxels/second
- Material efficiency: 100% cost
- Can build: Basic structures
- Structure HP bonus: 0%

**Level 50 (Master Builder):**
- Build speed: 20 voxels/second
- Material efficiency: 85% cost (saves 15% materials)
- Can build: Advanced structures
- Structure HP bonus: +25%

**Level 100 (Grand Architect):**
- Build speed: 30 voxels/second (3× normal!)
- Material efficiency: 75% cost (saves 25% materials!)
- Can build: Any structure, including Wonders
- Structure HP bonus: +50%
- Special ability: "Instant Repair" - Repair structures instantly (1 minute cooldown)

#### Scout (Level 1 → 100)

**Level 1 (Explorer):**
- Movement speed: 1.2× base
- Vision range: 20m
- Stealth: 0%
- Can detect: Enemy units

**Level 50 (Ranger):**
- Movement speed: 1.6× base
- Vision range: 40m
- Stealth: 50% (harder to detect)
- Can detect: Enemy units, hidden structures

**Level 100 (Master Scout):**
- Movement speed: 2.0× base (fastest peasant!)
- Vision range: 60m
- Stealth: 90% (nearly invisible)
- Can detect: Everything (enemy units, structures, traps, underground bases)
- Special ability: "Shadow Walk" - Invisible for 30 seconds (5 minute cooldown)

#### Engineer (Level 1 → 100)

**Level 1 (Novice Engineer):**
- Siege operation: 1.0× speed
- Siege accuracy: 50%
- Can operate: Catapult
- Repair speed: 1.0×

**Level 50 (Expert Engineer):**
- Siege operation: 1.5× speed
- Siege accuracy: 75%
- Can operate: Trebuchet, ram
- Repair speed: 2.0×

**Level 100 (Master Engineer):**
- Siege operation: 2.0× speed
- Siege accuracy: 95%
- Can operate: All siege weapons, can build advanced siege
- Repair speed: 3.0×
- Special ability: "Siege Master" - Siege weapons deal +50% damage when operated by Master Engineer

#### Diplomat (Level 1 → 100)

**Level 1 (Messenger):**
- Trade discount: 0%
- Alliance trust: 1.0×
- Can negotiate: Basic trade

**Level 50 (Ambassador):**
- Trade discount: 10%
- Alliance trust: 1.5×
- Can negotiate: Alliances, trade pacts

**Level 100 (Master Diplomat):**
- Trade discount: 25% (massive savings!)
- Alliance trust: 2.0× (easier to form alliances)
- Can negotiate: Everything, can break enemy alliances
- Special ability: "Silver Tongue" - Convert enemy peasants to your side (rare, 1% chance)

#### Saboteur (Level 1 → 100)

**Level 1 (Infiltrator):**
- Stealth: 25%
- Trap damage: 50
- Can sabotage: Basic structures

**Level 50 (Assassin):**
- Stealth: 65%
- Trap damage: 150
- Can sabotage: Advanced structures, can poison wells

**Level 100 (Master Saboteur):**
- Stealth: 95% (nearly undetectable)
- Trap damage: 300
- Can sabotage: Anything, can assassinate enemy Commander (very difficult)
- Special ability: "Ghost" - Completely invisible for 60 seconds (10 minute cooldown)

---

## Peasant Death Consequences

### AI Peasant Death (MAJOR LOSS)

**Unlike AoE II (disposable):**
- Losing a Level 50 Master Miner = HUGE economic loss
- Takes WEEKS of mining to level up replacement
- Players protect valuable high-level peasants
- Enemies target high-level peasants for strategic advantage

**Death Penalties by Level:**
- **Level 1-10**: Minor loss (1-2 days to replace)
- **Level 25**: Moderate loss (1 week to replace)
- **Level 50**: Major loss (2-3 weeks to replace)
- **Level 75**: Severe loss (1-2 months to replace)
- **Level 100**: Catastrophic loss (2-3+ months to replace)

**Replacement Process:**
1. Train new peasant (50 food + 30 seconds)
2. Assign to same vocation as lost peasant
3. Grind XP for weeks/months to reach same level
4. Re-unlock abilities and stats

**Strategic Implications:**
- **Don't send Level 100 Miner to dangerous areas**
- **Keep Master Warriors in reserve** (too valuable to risk casually)
- **Hide Master Farmers** in secure, protected locations
- **Evacuate high-level peasants** during sieges
- **Intelligence warfare**: Scout enemy bases, identify high-level peasants to assassinate

### Human Peasant Death (XP Loss)

**Death Consequences:**
- 30-second respawn at Town Center
- Drop all inventory (must recover items or lose them)
- Lose 5% of current level XP (painful but not devastating)
- Respawn with starting equipment (must re-equip from storage)

**Example:**
- Level 80 Warrior dies (2 million XP total)
- Loses 5% = 100,000 XP (drops to Level 78)
- Must regain 100,000 XP to return to Level 80
- Takes several hours of active combat

---

## Enemy Targeting High-Level Peasants

### Intelligence Gathering

**Scout enemy bases:**
- Identify which peasants are high-level (visual indicators)
- Report back to Commander
- Plan assassination missions

**Visual Indicators of High-Level Peasants:**
- **Level 1-25**: Basic peasant appearance
- **Level 26-50**: Better tools, slight armor
- **Level 51-75**: Distinct uniform, quality tools
- **Level 76-99**: Elite appearance, glowing tools
- **Level 100**: Legendary appearance, particle effects, title above name

### Assassination Missions

**Target Priority:**
- Level 100 Master Miner (cripples economy)
- Level 100 Elite Champion (removes military powerhouse)
- Level 100 Master Builder (slows construction)
- Level 100 Master Farmer (reduces food production)

**Assassination Tactics:**
- Send Master Saboteur to infiltrate
- Plant explosives near high-level peasants
- Snipe with trebuchet during siege
- Commander-led assassination (high risk, high reward)

---

## Protecting High-Level Peasants

### Strategic Positioning

**Safe zones:**
- Keep Level 75+ peasants inside walls
- Never send Master Miners to frontline mining
- Store high-level peasants in secure underground bases
- Evacuate during sieges (move to allied territory)

**Combat roles:**
- Level 100 Elite Champions fight ONLY in critical battles
- Never risk Level 100 Master Miner in combat zones
- Use low-level peasants for dangerous reconnaissance

### Evacuation Protocols

**During sieges:**
1. Commander orders evacuation of all Level 50+ peasants
2. High-level peasants flee to nearest ally territory
3. Low-level peasants fight as expendable defenders
4. After siege, high-level peasants return

---

## Peasant Four Evolution Stages

### Stage 1: Primitive (Starting)
- **Tools**: Wooden pickaxe, wooden axe
- **Speed**: Slow (1.0× movement)
- **Carry capacity**: 10 units
- **Can't mine**: Diamond, emerald, obsidian
- **Military**: Militia only (wooden spears)

### Stage 2: Road-Building (Iron Age)
- **Tools**: Iron pickaxe, iron axe
- **Speed**: Moderate (1.2× movement)
- **Carry capacity**: 20 units
- **Can mine**: Iron, coal, stone
- **Can build**: Roads (increase movement speed)
- **Military**: Infantry (iron swords), archers

### Stage 3: Wheel-Discovering (Steel Age)
- **Tools**: Steel pickaxe, steel axe
- **Speed**: Fast (1.5× movement with carts)
- **Carry capacity**: 50 units (with carts)
- **Can mine**: Gold, emerald
- **Can build**: Carts, advanced roads
- **Military**: Cavalry (mounted units), siege crew

### Stage 4: Advanced (Diamond Age)
- **Tools**: Diamond pickaxe, diamond axe
- **Speed**: Very fast (2.0× movement with hovercrafts)
- **Carry capacity**: 100 units (with hovercrafts)
- **Can mine**: Diamond, obsidian, all materials
- **Can build**: Hovercrafts, mega-structures
- **Military**: Elite knights, advanced siege

**Evolution Stages + Vocational Levels:**
- Primitive Level 50 Miner still only has wooden tools (limited by tech stage)
- Advanced Level 1 Miner has diamond tools but low efficiency (limited by level)
- Advanced Level 100 Master Miner is the ultimate peasant (both tech and skill maxed)

---

## Peasant Economy (AoE II-Style)

### Population System

**Housing Capacity:**
- **Town Center**: +5 population
- **House**: +5 population
- **Advanced House**: +10 population

**Population Limit:**
- Default: 200 peasants (like AoE II)
- Can be increased with tech research or game settings

**Food Upkeep:**
- Each peasant consumes 0.2 food/minute
- Starvation reduces work rate (-50%)
- No food = peasants stop working (don't die, just idle)

### Resource Gathering Rates (Modified by Vocation Level)

**Base Rates (Level 1 peasant):**
- Wood: 1.0 units/second
- Stone: 0.7 units/second
- Iron: 0.5 units/second
- Gold: 0.25 units/second
- Diamond: 0.1 units/second

**Level 100 Master Miner:**
- Wood: 3.0 units/second (3× faster!)
- Stone: 2.1 units/second
- Iron: 1.5 units/second
- Gold: 0.75 units/second
- Diamond: 0.3 units/second (3× faster!)

**Strategic Advantage:**
- One Level 100 Master Miner = THREE Level 1 peasants
- Protect your Master Miners at all costs!

---

## Construction System (Settlers II-Style)

### Physical Material Hauling

**The Process:**
1. **Commander places building** (marks foundation)
2. **Game calculates materials** (bill of materials from voxel design)
3. **Peasants gather materials** from storage buildings
4. **Peasants carry materials** to construction site (visible voxel clumps)
5. **Peasants build in stages** (foundation → walls → roof → complete)
6. **Building becomes functional** when 100% complete

**Construction Speed (Modified by Builder Level):**
- **Level 1 Builder**: 10 voxels/second
- **Level 50 Builder**: 20 voxels/second
- **Level 100 Master Builder**: 30 voxels/second (3× faster!)
- **Level 100 with material efficiency**: Saves 25% materials!

**Example:**
- Regular peasant builds house: 100 wood + 50 stone, 5 minutes
- Level 100 Master Builder: 75 wood + 37 stone, 1.7 minutes

---

## Military Conversion (Vocation Changes)

### Training Military Units

**From Peasants:**
- **Peasants enter Barracks** (or other military building)
- **Choose Warrior vocation** (locks vocation permanently)
- **Training time**: 30-60 seconds
- **Cost**: Food + resources (iron for infantry, wood for archers)
- **Retain XP/Level**: Peasant keeps accumulated XP and level!

**Example:**
- Level 50 Miner enters Barracks
- Converts to Level 50 Warrior
- Starts with Level 50 Warrior stats (better than Level 1 Warrior!)
- Can level up to Level 100 Elite Champion

**Strategic Choice:**
- Convert high-level peasant = powerful soldier immediately
- But lose valuable specialist (Level 50 Miner gone!)
- Risk vs reward: sacrifice economy for military power

---

## AI Behavior (Commander-Controlled)

### Auto-Task Finding

**Idle Peasant Logic:**
1. **Check food supply**: If low (<10 minutes), go farm
2. **Check construction**: If buildings incomplete, help build
3. **Check resources**: If storage low, go gather nearest needed resource
4. **Check repairs**: If buildings damaged, repair them
5. **Default**: Gather nearest abundant resource

**Priority System:**
- **Critical**: Food shortage (always highest priority)
- **High**: Commander-assigned tasks
- **Medium**: Construction projects, repairs
- **Low**: Resource gathering (abundant resources)

**Smart Vocation Assignment:**
- High-level miners assigned to rare materials
- High-level farmers manage food production
- High-level builders handle complex projects
- High-level warriors lead armies

---

## Co-Op Peasant Gameplay (FPS/RPG Experience)

### Human Peasant Experience

**Controls (FPS/TPS):**
- **WASD**: Movement
- **Mouse**: Look around, interact
- **E**: Interact (mine, build, open doors)
- **Q**: Drop/pickup items
- **Tab**: Inventory + Character Sheet (Level, XP, Stats)
- **1-5**: Hotbar (tools, weapons)
- **C**: Vocation abilities (Level 50+ unlocks special abilities)

**Progression Loop:**
1. Join as Level 1 peasant in chosen vocation
2. Perform actions to gain XP (mine, build, fight, scout)
3. Level up, unlock new stats and abilities
4. Become elite specialist over weeks of play
5. Become LEGENDARY if you reach Level 100

**Example Session:**
- Join as Level 1 Miner
- Mine 1,000 stone (2,000 XP) → Level 5
- Mine 500 iron (2,500 XP) → Level 10
- Mine 100 gold (1,000 XP) → Level 12
- Week later: Level 50 Master Miner (2.0× mining speed, can mine diamonds)
- Month later: Level 100 LEGENDARY Master Miner (3× speed, detect rare ores, tools last 2× longer)

**Death & Respawn:**
- 30-second respawn at Town Center
- Lose 5% of current level XP (painful!)
- Drop all inventory (must recover)
- Respawn with basic equipment

---

## Peasant Trolling & Comedy

### Peasant Cannon (Trebuchet Ammunition)

**The Mechanic:**
- Load peasant into trebuchet (instead of stone/wood)
- Launch peasant towards enemy base
- Peasant flies through the air (screaming sound effects)
- **Landing options**:
  - Death (85-95%): Peasant splatters on impact
  - Survival (5-15%): Peasant lands, becomes saboteur
  - Survival chance increases with level (Level 100 = 20% survival!)

**If Peasant Survives:**
- Sabotage mode: Sneak into enemy base
- Plant traps, steal resources, open gates
- High-risk, high-reward strategy

**Social Media Gold:**
- *"Launched Level 100 Master Miner, he survived and opened the gate!"*
- *"That legendary peasant survived 50 launches and retired"*

---

## The Peasant Experience

### For Solo Players (Commander Only)
- **Strategic control** like AoE II (select, assign, micro/macro)
- **Economic depth** (balance gathering, building, military)
- **Protect high-level peasants** (major strategic element)
- **Level up AI peasants** over weeks of gameplay

### For Co-Op Teams
- **Role specialization** (everyone masters their vocation)
- **FPS/RPG progression** (level 1 → 100 over time)
- **Social gaming** (friends leveling together)
- **Emergent gameplay** (high-level peasants become legends)

### For Viewers (Streaming)
- **Epic moments** (Level 100 peasant clutch saves)
- **Comedy gold** (peasant cannon with legendary peasant)
- **Character investment** (viewers root for favorite peasants)
- **Progression satisfaction** (watching peasants level up)

---

*From weak primitives to legendary masters. Every peasant has a story. Protect your masters, target enemy legends. Peasants are no longer disposable - they're your civilization's greatest asset.*
