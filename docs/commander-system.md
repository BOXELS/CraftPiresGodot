# Commander System

## Overview

The Commander is your civilization's leader and hero unit - a powerful miner, builder, and symbol of your empire. Inspired by Total Annihilation's Commander and Minecraft's player character, the Commander is both strategic controller and active participant in your civilization's story.

---

## Core Role

### Strategic Leadership

**Commander Abilities:**
- **Controls all AI peasants** (like AoE II player controls villagers)
- **Beam mining** (2× gathering speed, Dune-style laser extraction)
- **Fast building** (2× construction speed)
- **Command aura** (+10% morale/work rate to nearby units)
- **Tech research** (unlocks Commander-specific abilities)
- **Diplomatic power** (negotiate alliances, declare war)
- **XP strength** (strong, can level up over time with experience)

**In Co-Op Teams:**
- **1 Commander per civilization** (strategic leader)
- **Up to 9 human-controlled peasants** (team members)
- **Unlimited AI peasants** (Commander controls all)
- **Voice chat coordination** (real-time teamwork)
- **Strategic decisions** (Commander makes final calls)

### Beam Mining (Signature Mechanic)

**Dune-Style Extraction:**
- **Visible laser beam** locks onto voxel deposits
- **Pulls voxel clumps** directly into inventory (no walking to storage) has max capacity storage
- **Auto-refines** materials (converts raw ore to usable resources)
- **Terrain shaping** (visibly alters landscape with each extraction)
- **2× gathering speed** compared to peasants

**Mining Beam Mechanics:**
```
Range: 50m
Damage: N/A (mining only, not a weapon)
Gather Rate: 2.0 units/second (vs peasant 1.0 units/second)
Energy Cost: None (unlimited use)
Cooldown: None (continuous beam)
Visual: Colored beam (customizable via cosmetics)
```

**Example:**
- **Peasant mines stone**: 0.7 units/second, must walk to storage
- **Commander mines stone**: 1.4 units/second, instant storage

### Construction Speed

**Fast Builder:**
- **2× building speed** compared to peasants
- **Can place foundations** (only Commander can mark new building locations)
- **Can carry materials** (100 unit capacity, regardless of upgrades)
- **Can use tools** (pickaxe, axe, hammer for construction)

**Strategic Use:**
- **Early game**: Commander builds first structures quickly
- **Mid game**: Commander focuses on strategic resource gathering
- **Late game**: Commander coordinates armies, lets peasants build

---

## Combat Stats & Survival

### Base Stats

| Stat | Value |
|------|-------|
| HP | 300 |
| Speed | 1.5 |
| Attack | 30 |
| Armor | 10 |
| Range | 50m (beam mining), melee (combat) |
| Size | 2× normal peasant |

### Upgraded Stats (Fully Upgraded)

| Stat | Value |
|------|-------|
| HP | 600 |
| Speed | 1.8 |
| Attack | 50 |
| Armor | 25 |
| Range | 100m (beam mining), melee (combat) |
| Special | Material mastery abilities unlocked |

### Strengths

**What Commander is Good At:**
- **Tanking damage**: High HP and armor
- **Escaping**: Fast movement speed
- **Resource gathering**: Beam mining efficiency
- **Leading troops**: Command aura buffs nearby units
- **Assassination**: High attack damage can kill enemy peasants quickly

### Weaknesses

**What Commander is Vulnerable To:**
- **Siege weapons**: Trebuchets deal massive damage to Commander
- **Focused fire**: Multiple archers can overwhelm Commander
- **Traps**: Mud pits, fire traps, collapse traps
- **Assassinations**: Enemy Commanders or elite units
- **Ambush**: Surrounded by enemy army

**Design Intent:**
- **Commander is tough but NOT invincible**
- **Can be killed** with coordinated attack
- **Creates tension** (protect your Commander or lose efficiency)
- **Strategic target** (high-value assassination)

---

## Death & Respawn System

### Death Consequences

**Immediate Impact:**
- **Command aura lost**: -10% work rate empire-wide
- **Beam mining lost**: No 2× gathering speed
- **Building placement locked**: Can't mark new foundations
- **Morale penalty**: -20% combat effectiveness for all units
- **Strategic vulnerability**: Enemies know you're weakened

**Can Still Play:**
- **Peasants continue** existing tasks
- **AI automation** follows last orders
- **Military units** still fight (with morale penalty)
- **Buildings continue** functioning normally
- **Co-op teammates** (human peasants) continue playing

**Long-Term Consequences (If No Respawn):**
- **Slower economy**: No beam mining efficiency
- **Slower expansion**: Can't place new buildings
- **Weaker military**: Morale penalties persist
- **Diplomatic weakness**: Other players see you as vulnerable

### Respawn Mechanics

**Respawn Cost (Variable):**
- **Base cost**: 500 food + 300 stone + 200 gold
- **Additional materials**: Depending on terrain/circumstances
- **Time**: 5 minutes (peasants rebuild Commander)

**Process:**
1. **Commander dies** (voxel body drops at death location)
2. **Peasants must gather** Commander's voxel pieces (60-70% recoverable)
3. **Peasants carry pieces** to Town Center or Shrine
4. **Peasants rebuild Commander** (5-minute construction)
5. **Commander respawns** at rebuild location

**Unlimited Respawns:**
- **No maximum limit** (can respawn as many times as needed)
- **Cost scales slightly** (each death +10% cost)
- **Strategic choice**: Rebuild Commander vs build Wonder

**Enemy Capture:**
- **Enemies can steal** Commander voxel pieces if they reach death location first
- **Stolen pieces**: Enemy can rebuild as **Sub-Commander** (weaker version)
- **Sub-Commander stats**: 50% of original Commander (HP, damage, etc.)
- **Strategic gameplay**: Race to recover your Commander before enemies

**Example Respawn Scenarios:**
- **Quick respawn**: Pay cost, peasants rebuild in 5 minutes, Commander alive again
- **Delayed respawn**: Not enough resources, must gather more, Commander dead for 15+ minutes
- **Captured**: Enemies steal pieces, rebuild Sub-Commander, you must kill Sub-Commander to recover pieces

---

## Upgrade System: Material Mastery

### Tech-Driven Upgrades

**Age-Based Unlocks:**

**Age 1: Primitive Age Upgrades**
- **Masonry** (500 stone + 200 clay): +50% mining beam efficiency on stone
- **Agriculture** (300 food + 200 wood): +25% food production aura for nearby farms
- **Woodcrafting** (400 wood + 100 stone): +30% construction speed for wooden structures
- **Torchlight** (200 wood + 100 coal): Can use fire beam (light torches, ignite enemies)

**Age 2: Metal Age Upgrades**
- **Metallurgy** (800 iron + 400 coal): Iron armor (+100 HP, +5 armor)
- **Engineering** (600 iron + 300 wood + 200 stone): Can operate siege weapons directly
- **Coinage** (500 gold + 300 emerald): +50% trade efficiency aura
- **Smelting** (400 iron + 300 coal + 200 stone): +100% mining beam efficiency on ores
- **Fortification** (1000 stone + 500 iron + 200 clay): Can reinforce existing structures (+25% HP)

**Age 3: Gunpowder/Crystal Age Upgrades**
- **Gunpowder** (300 sulfur + 400 coal + 200 flint): Can craft and use explosive beam
- **Alchemy** (200 emerald + 100 diamond + 300 gold): Can transmute materials (rare conversions)
- **Industrial Logistics** (500 iron + 300 coal + 200 wood): +150% mining beam speed
- **Crystal Architecture** (300 emerald + 200 diamond + 400 stone): Crystal-powered structures
- **Hydrology** (600 stone + 400 clay + 300 iron): Can manipulate water sources (create/drain)

### Material Mastery Upgrades

**Iron Mastery** (200 iron)
- **Improved mining beam**: +50% gather rate on iron ore
- **Iron plating**: +30% armor
- **Visual**: Commander has iron plating visible on body

**Diamond Mastery** (10 diamonds)
- **Diamond armor**: +50% HP, critical hit resistance
- **Precision beam**: Can target specific voxel types (mine only diamonds in mixed terrain)
- **Visual**: Commander has diamond plating, glowing blue accents

**Emerald Mastery** (8 emeralds)
- **Diplomatic aura**: Better trade rates (−10% market fees) for nearby allies
- **Enhanced command radius**: +50% aura range (20m → 30m)
- **Visual**: Commander has emerald gems embedded, green glow

**Obsidian Mastery** (15 obsidian)
- **Fire immunity**: No damage from fire or lava
- **Can harvest lava**: Beam mining works on lava voxels (creates obsidian)
- **Visual**: Commander has dark obsidian plating, red glow

**Gold Mastery** (300 gold)
- **Elite training boost**: Military units train 50% faster near Commander
- **Reduced respawn cost**: −25% resources needed
- **Visual**: Commander has gold trim, yellow glow

**Coal Mastery** (150 coal)
- **Smelting beam**: Can refine ores 2× faster (iron ore → iron ingots)
- **Fire beam weapon**: Can ignite enemies/structures (15 damage/second)
- **Visual**: Commander beam has flame effect, orange glow

### Upgrade Progression

**Early Game (Age 1):**
- Focus on **economic upgrades** (masonry, agriculture, woodcrafting)
- Unlock **basic masteries** (iron, coal)
- **Cost**: 500-1,000 total resources

**Mid Game (Age 2):**
- Focus on **military upgrades** (metallurgy, engineering, fortification)
- Unlock **advanced masteries** (gold, obsidian)
- **Cost**: 2,000-5,000 total resources

**Late Game (Age 3):**
- Focus on **power upgrades** (gunpowder, alchemy, crystal architecture)
- Unlock **elite masteries** (diamond, emerald)
- **Cost**: 5,000-15,000 total resources

**Full Progression Example:**
1. **Primitive Commander** (Age 1, no upgrades): HP 300, mining 2×, basic abilities
2. **Iron Commander** (Age 2, Iron + Metallurgy): HP 400, mining 3×, iron armor
3. **Diamond Commander** (Age 3, Diamond + Crystal): HP 600, mining 5×, precision beam, diamond armor
4. **Master Commander** (All upgrades): HP 600, mining 5×, all abilities, looks legendary

---

## Strategic Importance

### Why Protect Your Commander

**Economic Reasons:**
- **Beam mining**: 2× gathering speed (massive efficiency boost)
- **Fast building**: 2× construction speed (rapid expansion)
- **Command aura**: +10% work rate empire-wide (compounds over time)

**Military Reasons:**
- **Morale**: Troops fight 20% better with Commander alive
- **Siege operation**: Can operate siege weapons directly
- **Elite training**: Military units train faster near Commander

**Diplomatic Reasons:**
- **Alliance credibility**: Allies trust leaders who survive
- **Enemy fear**: Strong Commander deters attacks
- **Trade efficiency**: Better trade rates with trade aura

**Resource Reasons:**
- **Respawn cost**: 500-1,000+ resources (expensive in late game)
- **Lost productivity**: 5+ minutes without Commander is huge economic loss
- **Opportunity cost**: Resources spent on respawn can't build Wonder

### Why Target Enemy Commanders

**Economic Warfare:**
- **Cripple economy**: Remove their 2× beam mining efficiency
- **Slow expansion**: Can't place new buildings without Commander
- **Resource drain**: Force them to spend 500-1,000 resources on respawn

**Military Advantage:**
- **Morale collapse**: Enemy troops fight 20% worse
- **Disable siege**: Can't operate siege weapons without Commander
- **Weaken defenses**: No command aura to buff defenders

**Strategic Goals:**
- **High-value target**: 200 prestige for Commander kill
- **Psychological impact**: Demoralizes enemy team
- **Capture opportunity**: Steal Commander pieces, rebuild Sub-Commander

**Prestige Reward:**
- **Commander kill**: 200 prestige
- **Sub-Commander creation**: 100 prestige (if you capture pieces)
- **Legendary assassination**: 500 prestige (if enemy Commander was high-level)

---

## Commander Playstyles

### Aggressive Commander (High Risk, High Reward)

**Strategy:**
- **Frontline fighting**: Lead armies into battle
- **Siege operations**: Personally operate trebuchets
- **Enemy harassment**: Raid enemy economy, kill peasants
- **Commander duels**: Fight enemy Commanders directly

**Pros:**
- **High prestige**: Many kills, epic battles
- **Fast victories**: Aggressive play wins battles quickly
- **Intimidation**: Enemies fear aggressive Commanders

**Cons:**
- **High death risk**: Frequent respawns drain resources
- **Economic sacrifice**: Time spent fighting = less gathering
- **Target on back**: Everyone wants to kill the aggressive Commander

### Defensive Commander (Low Risk, Steady Progress)

**Strategy:**
- **Economy focus**: Beam mining, resource gathering
- **Base building**: Construct defenses, expand territory
- **Safe positioning**: Stay behind walls, let peasants fight
- **Late-game power**: Accumulate massive resources

**Pros:**
- **Economic efficiency**: Maximize beam mining uptime
- **Survival**: Rarely dies, no respawn costs
- **Long-term strength**: Out-economy opponents

**Cons:**
- **Slow victories**: Takes longer to win
- **Less prestige**: Fewer kills, less dramatic
- **Vulnerable to rush**: Aggressive enemies can exploit early weakness

### Balanced Commander (Flexible)

**Strategy:**
- **Early game**: Focus on economy (beam mining, building)
- **Mid game**: Join battles when needed (command aura support)
- **Late game**: Lead sieges, coordinate alliances
- **Adaptive**: Switch between aggressive and defensive as needed

**Pros:**
- **Well-rounded**: Strong economy AND military presence
- **Flexible**: Can adapt to any situation
- **Team coordination**: Best for co-op teams (humans + AI)

**Cons:**
- **Jack-of-all-trades**: Not specialized in any one area
- **Medium prestige**: Not the highest kills, not the highest economy
- **Requires skill**: Must know when to fight vs when to build

---

## Offline & AI Automation

### When Offline (Commander Away)

**AI Behavior:**
- **Defensive stance**: Commander stays in Town Center or designated safe location
- **No risky actions**: Won't leave base, won't engage enemies
- **Beam mining**: Continues gathering nearby resources (within 50m of safe location)
- **Emergency retreat**: If base attacked, Commander hides in underground bunker

**Customizable Settings:**
- **Gather priority**: Focus on wood, stone, food, or balanced
- **Safety zone**: Define area Commander stays in when offline
- **Emergency actions**: Auto-spend resources to respawn if killed
- **Alliance support**: Auto-send resources to allies if needed

### When Abandoned (Player Quits)

**Civilization Continues:**
- **AI takes over**: Commander becomes AI-controlled
- **Basic automation**: Gather resources, defend base, maintain economy
- **No expansion**: Won't place new buildings or attack enemies
- **Decay over time**: Structures slowly lose HP (1% per day after 7 days)

**Player Can Return:**
- **Rejoin anytime**: Same Commander, same civilization
- **Progress persists**: All structures, resources, peasants intact
- **Offline penalties**: Structures may be damaged, resources may be low
- **Recovery possible**: Can rebuild and catch up

---

## Prestige & Season Impact

### Prestige Earnings

**Commander Actions:**
- **Kill enemy Commander**: 200 prestige
- **Capture enemy Commander pieces**: 100 prestige
- **Build Wonder**: 1,000 prestige
- **Win siege**: 50-200 prestige (depending on size)
- **Tech research**: 10-50 prestige per tech

**Prestige Penalties:**
- **Die frequently**: −10 prestige per death after 5th death in season
- **Abandoned civilization**: −100 prestige if offline for 30+ days

**Season-End Achievements:**
- **"Immortal Commander"**: 2,000 prestige (zero deaths entire season)
- **"Phoenix Commander"**: 1,000 prestige (died 10+ times but still won)
- **"Master Builder"**: 1,500 prestige (built 100+ structures)
- **"Siege Master"**: 1,800 prestige (won 50+ sieges)

### Season Carryover

**What Carries Over:**
- **Commander cosmetics**: Skins, beam colors, animations
- **Starting bonuses**: +10% starting resources per previous season
- **Recognition**: Hall of Legends entry, titles, achievements
- **Blueprint library**: Custom building designs

**What Resets:**
- **Commander stats**: Back to base (HP 300, etc.)
- **Material masteries**: Must re-research all upgrades
- **Civilization**: Must rebuild from scratch
- **Territory**: No land ownership carries over

---

## Balancing Guardrails

### Power Caps

**Commander Never:**
- **Solos entire armies**: Can't 1v20 peasants
- **Instant-kills structures**: Beam mining takes time
- **Becomes invincible**: Always vulnerable to coordinated attack
- **One-shots other Commanders**: Fair 1v1 duels (skill-based)

**Resource Pressure:**
- **Respawn costs scale**: Each death +10% cost
- **Late-game scarcity**: Diamond/emerald needed for elite upgrades
- **Strategic choice**: Respawn Commander OR build Wonder (can't do both immediately)

### Risk vs Reward

**High Risk:**
- **Aggressive Commander**: Die often, high respawn costs
- **Frontline building**: Commander exposed while placing foundations
- **Siege operations**: Commander vulnerable while using trebuchet

**High Reward:**
- **Beam mining efficiency**: 2× gathering = faster economy
- **Command aura**: +10% empire-wide = compounds over time
- **Prestige**: Commander kills = fame and recognition

---

## The "Steve" Fantasy → **F mode** (embodied play)

Your Commander should feel like:
- ✅ The heart of your civilization
- ✅ A character you care about losing
- ✅ A strategic asset worth protecting
- ✅ An extension of your playstyle
- ✅ The architect of your empire's unique identity
- ✅ A hero with a legendary story

Not:
- ❌ A generic hero unit
- ❌ Invincible god mode
- ❌ A pure combat unit
- ❌ Easily replaceable
- ❌ Just another peasant with buffs

### Dual audience (confirmed design)

CraftPires serves two valid ways to drive the same civilization:

| Audience | How they play the Commander / workers | Buildings |
| --- | --- | --- |
| **AoE II / Settlers** | RTS camera; select units; Shift+LMB orders; beam as leader ability | Research Hall, Toolsmith, Weaponsmith = primary craft/research loop |
| **Embodied / “F mode”** | Press **F** on Commander *or any peasant* → possess that unit | Same recipes & unlocks, done **by hand** while possessed — Hall/smiths optional |

**F mode** is the product name for embodied first-/third-person work (we do not brand it as Minecraft in UI). It is an **alternative path through the same progress flow**, not a second tech tree. Locomotion while possessed: WASD, Space jump, Ctrl run (Commander body-check), Shift crouch — help chrome swaps off the RTS sheet.

Full rules: [`crafting-tools-system.md` → F mode](./crafting-tools-system.md#f-mode-embodied-craft--research).

---

*Your Commander. Your civilization. Your legend.*
