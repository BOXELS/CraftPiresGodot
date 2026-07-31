# Tech Progression System

## Overview

**CraftPires blends Empire Earth's epochs with Civilization's branching research** to create a progression system where civilizations evolve through distinct ages while making meaningful choices about their specialization. Resource mining directly unlocks technologies, making every civilization's path unique based on their environment and choices.

**Civ packs (AoE II–style):** shared age spine + per-civ unique techs/units.
The prototype builds **Larpites** (`civId: larpites`) as the original starter
pack — see [`civilizations.md`](./civilizations.md). Hang unique techs on that
schema; do not fork the age system per civ.

---

## The Three-Age System (Empire Earth-Inspired)

### Age 1: Primitive Age
**Starting point** - Dirt huts, wood tools, basic defenses
**Unlock condition** - Start of the game (automatic)
**Focus** - Basic survival and infrastructure
**Peasant stage**: Primitive (wooden tools, 10 unit carry capacity)

### Age 2: Metal Age  
**Unlock condition** - 500 food + 300 stone + Barracks built
**Focus** - Advanced tools, real siege warfare begins
**Strategic depth** - Military vs economic specialization
**Peasant stage**: Road-Building → Wheel-Discovering (iron/steel tools, carts)
**Settlement (design)** - Unlock **Found Keep** + road paving; still playable
on one Keep. See [`settlement-territory.md`](./settlement-territory.md).

### Age 3: Gunpowder/Crystal Age
**Unlock condition** - 2,000 food + 1,500 stone + 500 gold + 100 iron + Castle built
**Focus** - Explosive power, diplomacy, advanced infrastructure
**Endgame complexity** - Multiple victory paths
**Peasant stage**: Advanced (diamond tools, hovercrafts, 100 unit carry capacity)
**Settlement (design)** - **Hard gate: ≥ 2 complete Keeps**, road-linked, with
army/pop budgets scaling per Keep ([`settlement-territory.md`](./settlement-territory.md)).

---

## Age 1: Primitive Age

### Starting Technologies

**Masonry** (500 stone + 200 clay)
- **Unlocks**: Stone walls, stronger Town Center foundations
- **Commander upgrade**: +50% mining beam efficiency on stone
- **Strategic value**: Defensive focus, foundation for larger structures
- **Peasant benefit**: Can build with stone more efficiently

**Agriculture** (300 food + 200 wood)
- **Unlocks**: Farms, increased food storage, faster population growth
- **Commander upgrade**: +25% food production from farms in command aura range
- **Strategic value**: Economic focus, population boom potential (more peasants)
- **Peasant benefit**: Farms produce more food

**Woodcrafting** (400 wood + 100 stone)
- **Unlocks**: Improved wooden defenses, wooden siege (battering rams)
- **Commander upgrade**: +30% construction speed for wooden structures
- **Strategic value**: Early offensive capabilities, resource efficiency
- **Peasant benefit**: Build wooden structures faster

**Torchlight** (200 wood + 100 coal)
- **Unlocks**: Fire arrows, torches for lighting, early fire warfare
- **Commander upgrade**: Fire beam ability (+20% damage with fire weapons)
- **Strategic value**: Early siege warfare, psychological warfare
- **Peasant benefit**: Can use fire arrows in combat

### Branching Choices

**Defensive Path**: Masonry → Fortification (Age 2)
- **Focus**: Strong defensive structures, stone walls
- **Playstyle**: Turtle and build, defensive warfare, wonder construction
- **Advantages**: Hard to destroy, safe expansion, can outlast enemies
- **Disadvantages**: Slow early game, limited offensive options, resource intensive

**Economic Path**: Agriculture → Coinage (Age 2)
- **Focus**: Resource production and trade, max peasants
- **Playstyle**: Boom economy, trade with allies, peaceful expansion
- **Advantages**: Rich civilization, can buy victory, fastest peasant growth
- **Disadvantages**: Vulnerable to early rushes, requires protection

**Offensive Path**: Woodcrafting + Torchlight → Engineering (Age 2)
- **Focus**: Early warfare and siege, military dominance
- **Playstyle**: Aggressive expansion, early attacks, territory conquest
- **Advantages**: Early military dominance, can eliminate weak neighbors
- **Disadvantages**: Resource intensive, vulnerable to counter-attacks, slow economy

---

## Age 2: Metal Age

### Unlock Requirements
- **Resource cost**: 500 food + 300 stone
- **Building requirements**: Town Center + 2 Houses + Barracks
- **Time**: 5 minutes research time
- **Effect**: Unlocks Age 2 technologies and peasant upgrades

### Available Technologies

**Metallurgy** (800 iron + 400 coal)
- **Unlocks**: Iron weapons, armor, iron-reinforced structures
- **Commander upgrade**: Iron armor (+100 HP, +5 armor)
- **Peasant upgrade**: Can use iron tools (+15% gather rate)
- **Strategic value**: Military dominance, stronger structures

**Engineering** (600 iron + 300 wood + 200 stone)
- **Unlocks**: Trebuchets/catapults with stone or explosive ammo
- **Commander upgrade**: Can operate siege weapons directly
- **Peasant upgrade**: Can crew siege weapons (+50% efficiency)
- **Strategic value**: Long-range warfare, siege capabilities

**Coinage** (500 gold + 300 emerald)
- **Unlocks**: Trade posts, market efficiency, emerald/gold bonuses
- **Commander upgrade**: +50% trade efficiency (−10% market fees)
- **Peasant upgrade**: Faster resource trading
- **Strategic value**: Economic growth, alliance building

**Smelting** (400 iron + 300 coal + 200 stone)
- **Unlocks**: Improved mining efficiency, smelter buildings
- **Commander upgrade**: +100% mining beam efficiency on ores
- **Peasant upgrade**: +30% ore gathering speed
- **Strategic value**: Resource production, economic advantage

**Fortification** (1,000 stone + 500 iron + 200 clay)
- **Unlocks**: Stone + iron walls, tunnel collapse resistance
- **Commander upgrade**: Can reinforce existing structures (+25% HP)
- **Peasant upgrade**: Can build defensive structures faster
- **Strategic value**: Defensive superiority, tunnel warfare resistance

**Wheelbarrow** (800 food + 400 wood)
- **Unlocks**: Increased carry capacity for peasants
- **Commander upgrade**: None (peasant-focused tech)
- **Peasant upgrade**: +25% carry capacity (20 → 25 units)
- **Strategic value**: Economic efficiency, faster construction

### Branching Choices

**Military Dominance Path**: Metallurgy + Engineering
- **Focus**: Superior weapons and siege warfare
- **Playstyle**: Aggressive expansion, military superiority, conquest
- **Advantages**: Strongest military, can conquer others, intimidation factor
- **Disadvantages**: Resource intensive, diplomatic isolation, slow economy

**Economic Growth Path**: Coinage + Smelting + Wheelbarrow
- **Focus**: Resource production and trade efficiency
- **Playstyle**: Economic boom, trade partnerships, alliance building
- **Advantages**: Richest civilization, can buy allies, fastest tech progression
- **Disadvantages**: Vulnerable to military attacks, depends on allies

**Defensive Mastery Path**: Fortification + Metallurgy + Smelting
- **Focus**: Impenetrable defenses and resource efficiency
- **Playstyle**: Defensive warfare, attrition battles, outlast enemies
- **Advantages**: Hardest to destroy, can outlast enemies, safe wonder construction
- **Disadvantages**: Limited offensive capabilities, slow expansion

---

## Age 3: Gunpowder/Crystal Age

### Unlock Requirements
- **Resource cost**: 2,000 food + 1,500 stone + 500 gold + 100 iron
- **Building requirements**: Castle Age + 2 military buildings
- **Time**: 15 minutes research time
- **Effect**: Unlocks Age 3 technologies and advanced peasant stage

### Unlock Paths
**Path A (Gunpowder)**: Acquire 500+ sulfur + 500+ coal + 300+ flint
**Path B (Crystal)**: Acquire 200+ emerald + 100+ diamond
**Path C (Balanced)**: Complete 3+ Age 2 technologies + requirements above

### Available Technologies

**Gunpowder** (300 sulfur + 400 coal + 200 flint)
- **Unlocks**: Cannons, bombs, explosive trebuchet ammo, bombards
- **Commander upgrade**: Explosive beam weapon (area damage)
- **Peasant upgrade**: Can use gunpowder weapons (bombard crew)
- **Strategic value**: Devastating offensive power, structure destruction

**Alchemy** (200 emerald + 100 diamond + 300 gold)
- **Unlocks**: Resource transmutation, diplomatic bonuses, special combinations
- **Commander upgrade**: Can transmute materials (rare conversions)
- **Peasant upgrade**: Can assist in alchemy (boost production)
- **Strategic value**: Diplomatic advantages, unique abilities, flexibility

**Industrial Logistics** (500 iron + 300 coal + 200 wood)
- **Unlocks**: Automated hauling systems, advanced supply chains
- **Commander upgrade**: +150% mining beam speed, instant storage
- **Peasant upgrade**: Hovercrafts unlocked (3× transport speed, 100 unit capacity)
- **Strategic value**: Economic efficiency, reduced micromanagement, rapid construction

**Crystal Architecture** (300 emerald + 200 diamond + 400 stone)
- **Unlocks**: Gem-encrusted structures, glowing monuments, special buffs
- **Commander upgrade**: Can create crystal-powered structures (unique bonuses)
- **Peasant upgrade**: Can work with crystal materials
- **Strategic value**: Prestige, unique defensive capabilities, wonder enhancement

**Hydrology** (600 stone + 400 clay + 300 iron)
- **Unlocks**: Dams, flooding systems, river redirection, water control
- **Commander upgrade**: Can manipulate water sources (create/drain/redirect)
- **Peasant upgrade**: Can build hydraulic structures
- **Strategic value**: Environmental warfare, infrastructure control, strategic flooding

**Chemistry** (300 sulfur + 400 coal + 200 gold)
- **Unlocks**: Advanced gunpowder weapons, explosive mining
- **Commander upgrade**: Enhanced explosive beam (2× damage)
- **Peasant upgrade**: Can use advanced explosives
- **Strategic value**: Ultimate destructive power, terrain reshaping

### Branching Choices

**Military Devastation Path**: Gunpowder + Chemistry + Industrial Logistics
- **Focus**: Maximum destructive power and logistical efficiency
- **Playstyle**: Total war, resource denial, scorched earth
- **Advantages**: Can destroy any target, economic warfare, fastest military
- **Disadvantages**: Very expensive, diplomatic isolation, resource drain

**Prestige/Diplomacy Path**: Alchemy + Crystal Architecture
- **Focus**: Diplomatic advantages and unique capabilities
- **Playstyle**: Alliance building, prestige monuments, wonder construction
- **Advantages**: Strong alliances, unique abilities, aesthetic dominance, prestige victory
- **Disadvantages**: Expensive, requires rare resources, vulnerable to military

**Infrastructure Dominance Path**: Hydrology + Industrial Logistics + Crystal Architecture
- **Focus**: Environmental control and economic efficiency
- **Playstyle**: Resource control, infrastructure warfare, wonder construction
- **Advantages**: Control key resources, economic superiority, environmental weapons
- **Disadvantages**: Complex to execute, requires planning, expensive

---

## Resource-Driven Progression

### How Resources Unlock Technologies

**Direct Resource Requirements:**
- **Age 1**: Wood, stone, food (abundant, easy access)
- **Age 2**: Iron, coal, gold (moderate difficulty, requires mining)
- **Age 3**: Sulfur, emerald, diamond (rare, competitive, strategic locations)

**Environmental Influence:**
- **Iron-rich areas** → Natural military focus (Metallurgy, Engineering)
- **Emerald deposits** → Diplomatic advantages (Coinage, Alchemy)
- **Sulfur mines** → Gunpowder specialization (Gunpowder, Chemistry)
- **Diamond sources** → Crystal architecture (Crystal Architecture, prestige builds)

**Strategic Implications:**
- **Different starting positions** → Different natural tech paths
- **Resource competition** → Warfare over key technologies
- **Alliance benefits** → Share rare resources for tech unlocks
- **Replayability** → Every shard forces new strategies based on biome

### Commander as Research Lab

**No Abstract Research Points:**
- **Commander channels resources** directly into tech research
- **Physical resources consumed** (not invisible research points)
- **Research building** (optional): Lab speeds up research by 50%
- **Map + resources + choices** = unique tech path each season

**Research Process:**
1. **Commander selects technology** to research
2. **Peasants deliver resources** to Town Center or Lab
3. **Research progress bar** shows completion (5-15 minutes)
4. **Technology unlocks** when complete
5. **Commander gains upgrade** immediately

---

## Peasant Progression Through Ages

### Age 1: Primitive Peasants
- **Tools**: Wooden pickaxe, wooden axe
- **Carry capacity**: 10 units
- **Movement**: 1.0× base speed
- **Can mine**: Wood, stone, food, clay (NOT iron, gold, diamond)
- **Military**: Can train to Militia (wooden spears)

### Age 2: Road-Building/Wheel-Discovering Peasants
- **Tools**: Iron pickaxe (Age 2) → Steel pickaxe (late Age 2)
- **Carry capacity**: 20 units (iron) → 50 units (with carts after Wheelbarrow)
- **Movement**: 1.2× speed → 1.5× speed (with carts)
- **Can mine**: Iron, coal, gold, emerald (NOT diamond, obsidian)
- **Military**: Infantry, archers, cavalry, siege crew
- **Special**: Can build roads (+50% movement speed on roads)

### Age 3: Advanced Peasants
- **Tools**: Diamond pickaxe, diamond axe
- **Carry capacity**: 100 units (with hovercrafts after Industrial Logistics)
- **Movement**: 2.0× speed (with hovercrafts)
- **Can mine**: Diamond, obsidian, all materials
- **Military**: Elite knights, bombard crew, advanced siege
- **Special**: Can build hovercrafts, mega-structures, wonders

---

## Commander Upgrades by Age

### Age 1 Commander Upgrades
- **Base stats**: HP 300, Damage 30, Armor 10, Speed 1.5
- **Masonry**: +50% mining beam efficiency on stone
- **Agriculture**: +25% food production aura for nearby farms
- **Woodcrafting**: +30% construction speed for wooden structures
- **Torchlight**: Fire beam ability (+20% damage with fire)

### Age 2 Commander Upgrades
- **Base stats**: HP 400, Damage 35, Armor 15, Speed 1.6
- **Metallurgy**: Iron armor (+100 HP, +5 armor, total: 500 HP, 20 armor)
- **Engineering**: Can operate siege weapons directly (no crew needed)
- **Coinage**: +50% trade efficiency (−10% market fees in aura range)
- **Smelting**: +100% mining beam efficiency on ores (total: 3× peasant speed)
- **Fortification**: Can reinforce structures (+25% HP to existing buildings)

### Age 3 Commander Upgrades
- **Base stats**: HP 600, Damage 50, Armor 25, Speed 1.8
- **Gunpowder**: Explosive beam weapon (area damage, structure destruction)
- **Alchemy**: Can transmute materials (rare conversions, flexible economy)
- **Industrial Logistics**: +150% mining beam speed (total: 5× peasant speed)
- **Crystal Architecture**: Can create crystal-powered structures (unique buffs)
- **Hydrology**: Can manipulate water (create/drain/redirect rivers, lakes)
- **Chemistry**: Enhanced explosive beam (2× gunpowder damage)

---

## Strategic Depth & Replayability

### No Civilization Can Unlock Everything

**Resource Scarcity:**
- **Limited rare materials**: Can't afford all Age 3 techs
- **Strategic choices**: Choose 2-3 Age 3 techs maximum per season
- **Trade-offs**: Military vs economy vs prestige vs infrastructure

**Environmental Constraints:**
- **Desert shard**: Abundant gold/sulfur → Gunpowder/Coinage natural path
- **Forest shard**: Abundant wood/emerald → Alchemy/Crystal natural path
- **Mountain shard**: Abundant iron/coal → Metallurgy/Engineering natural path
- **Volcanic shard**: Abundant obsidian/sulfur → Gunpowder/Fortification natural path

### Alliance Tech Sharing

**Resource Trading:**
- **Ally has sulfur**: Trade for emeralds to unlock both Gunpowder and Alchemy paths
- **Ally has diamond**: Share for Crystal Architecture research
- **Strategic alliances**: Form around complementary resource access

**Tech Specialization:**
- **Military alliance**: One civ Gunpowder, another Metallurgy (combined arms)
- **Economic alliance**: One civ Coinage, another Smelting (trade efficiency)
- **Wonder alliance**: Multiple civs contribute resources for Crystal Architecture

---

## Mid-Game Power Spikes

### Age 2 Unlock (Most Important)
- **Siege weapons available**: Game transforms from skirmishes to sieges
- **Iron weapons**: 2× damage compared to Age 1 wooden weapons
- **Economic explosion**: Wheelbarrow + Smelting = 2× resource gathering
- **First major wars**: Civilizations that reach Age 2 first dominate

### Age 3 Unlock (Endgame)
- **Explosive power**: Gunpowder changes warfare completely
- **Wonder construction**: Only Age 3 civs can build wonders (prestige victory)
- **Hovertrafts**: 3× faster construction due to transport efficiency
- **Diplomatic power**: Alchemy enables flexible economy and alliances

---

## Balance Considerations

### Age Timing

**Typical Progression:**
- **Age 1**: Days 1-7 (week 1)
- **Age 2**: Days 8-30 (weeks 2-4)
- **Age 3**: Days 31-365 (months 2-12)

**Rush Strategies:**
- **Fast Age 2**: Day 5 rush (sacrifice economy for early military advantage)
- **Wonder rush**: Fast Age 3 + Crystal Architecture (risky, high reward)
- **Economic boom**: Stay Age 1 longer, build massive economy, then dominate Age 2-3

### Tech Cost Scaling

**Age 1 Techs**: 200-500 total resources
**Age 2 Techs**: 800-1,500 total resources
**Age 3 Techs**: 1,500-3,000 total resources

**Research Time:**
- **Age 1**: 2-5 minutes per tech
- **Age 2**: 5-10 minutes per tech
- **Age 3**: 10-20 minutes per tech

---

## The Experience

### For Solo Players (Commander Only)
- **Economic strategy**: Choose tech path based on available resources
- **Military timing**: Balance economic boom vs early aggression
- **Tech choices**: Specialize or diversify based on strategy
- **Adaptation**: Adjust tech path based on enemy strategies

### For Co-Op Teams (10 Players)
- **Coordination**: Team decides tech path together (voice chat)
- **Specialization**: Different peasants focus on different resource gathering
- **Strategic planning**: Long-term tech goals require team buy-in
- **Resource sharing**: Peasants deliver resources for Commander research

### For Alliances
- **Tech sharing**: Trade rare resources for complementary tech unlocks
- **Combined arms**: Coordinate specialized tech paths for synergy
- **Wonder construction**: Pool resources for Crystal Architecture
- **Strategic dominance**: Allied tech superiority overwhelming

---

## Technical Implementation

### Tech Tree Data Structure
```typescript
interface Technology {
  id: string;
  name: string;
  age: 1 | 2 | 3;
  prerequisites: string[]; // Other tech IDs required
  resourceCost: {
    food?: number;
    wood?: number;
    stone?: number;
    iron?: number;
    coal?: number;
    gold?: number;
    sulfur?: number;
    emerald?: number;
    diamond?: number;
  };
  researchTime: number; // Seconds
  unlocks: string[]; // Building/unit IDs unlocked
  commanderUpgrade: {
    hp?: number;
    damage?: number;
    armor?: number;
    speed?: number;
    ability?: string;
  };
  peasantUpgrade: {
    gatherRate?: number;
    carryCapacity?: number;
    buildSpeed?: number;
    ability?: string;
  };
}
```

### Research System
```typescript
function startResearch(civ: Civilization, tech: Technology): boolean {
  // Check prerequisites
  if (!civ.hasPrerequisites(tech.prerequisites)) {
    return false;
  }
  
  // Check resources
  if (!civ.hasResources(tech.resourceCost)) {
    return false;
  }
  
  // Consume resources
  civ.spendResources(tech.resourceCost);
  
  // Start research timer
  civ.research.currentTech = tech;
  civ.research.startTime = Date.now();
  civ.research.completeTime = Date.now() + (tech.researchTime * 1000);
  
  return true;
}

function checkResearchComplete(civ: Civilization): void {
  if (!civ.research.currentTech) return;
  
  if (Date.now() >= civ.research.completeTime) {
    const tech = civ.research.currentTech;
    
    // Unlock technology
    civ.technologies.push(tech.id);
    
    // Apply Commander upgrades
    if (tech.commanderUpgrade) {
      civ.commander.applyUpgrade(tech.commanderUpgrade);
    }
    
    // Apply Peasant upgrades
    if (tech.peasantUpgrade) {
      civ.peasants.forEach(p => p.applyUpgrade(tech.peasantUpgrade));
    }
    
    // Unlock new buildings/units
    tech.unlocks.forEach(id => civ.unlockBuildingOrUnit(id));
    
    // Clear research
    civ.research.currentTech = null;
  }
}
```

---

## The Vision

**This creates a world where:**
- **Every civilization evolves** through distinct ages with meaningful progression
- **Resource mining directly unlocks** technologies (no abstract research points)
- **Player choices create** unique civilization identities and strategies
- **Environmental factors** shape development paths and force adaptation
- **Alliance dynamics** influence tech progression through resource sharing
- **No civilization dominates** - specialization creates rock-paper-scissors balance
- **Replayability** from different resource distributions each season
- **Strategic depth** from branching choices and trade-offs

---

*From primitive dirt huts with wooden tools to crystal-powered monuments with explosive weapons. Every civilization's journey is unique, shaped by resources, choices, and alliances. Will you dominate through military might, economic prosperity, or prestigious diplomacy?*
