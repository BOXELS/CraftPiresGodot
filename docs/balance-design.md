# Balance & Design Considerations

## Core Balance Philosophy

1. **Resources have meaningful trade-offs** - No single "best" material
2. **Skill > Time** - Clever play beats grinding
3. **Comebacks are possible** - Never truly out of the game
4. **Cooperation encouraged** - Alliances are powerful but vulnerable
5. **No pay-to-win** - Prestige = cosmetics + minor QoL only

## Resource Balance

### Material Efficiency

**Construction Value** (HP per resource unit)

| Material | HP/Unit | Cost | Best Use |
|----------|---------|------|----------|
| Dirt | 5 | Very cheap | Mass production, earthworks |
| Wood | 8 | Cheap | Early game, temporary structures |
| Clay | 12 | Medium | Mid-tier buildings, housing |
| Stone | 15 | Medium | Walls, foundations |
| Iron | 20 | Expensive | Gates, military structures |
| Obsidian | 25 | Very expensive | Fire-resistant, premium defense |
| Diamond | 30 | Extremely rare | Critical structures, prestige |

**Ammo Efficiency** (Damage per resource unit)

| Material | Damage/Unit | Special Effect | Strategy |
|----------|-------------|----------------|----------|
| Dirt | 0.1 | Terrain fill | Spam, area denial |
| Wood | 0.3 | Fire (if ignited) | Cheap harassment |
| Stone | 0.5 | Structure damage | Standard siege |
| Iron | 1.0 | Armor penetration | Precision strikes |
| Coal | 0.4 | Burns area | Area denial |
| Gunpowder | 2.5 | AoE explosion | High-value targets |
| Diamond | 3.0 | Massive single-target | Commander/wonder assassination |

### Resource Scarcity

**Spawn Rates** (per chunk, per biome adjusted)

- **Common** (Wood, Stone, Food): 80-100/chunk
- **Uncommon** (Clay, Iron, Coal): 20-30/chunk
- **Rare** (Gold, Obsidian): 5-10/chunk
- **Very Rare** (Diamond, Emerald): 1-3/chunk

**Gather Rates** (base, per villager)

- Wood: 1.0/s
- Stone: 0.7/s
- Food: Varies (farm cycle)
- Clay: 0.6/s
- Iron: 0.5/s
- Coal: 0.5/s
- Gold: 0.25/s
- Diamond: 0.1/s
- Emerald: 0.15/s
- Obsidian: 0.08/s

**Commander Bonus**: 2× gather rate

### Economic Balance

**Building Costs** (Prefabs)

- House: 100 wood + 50 stone (provides +5 pop)
- Town Center: 500 stone + 200 wood (spawns villagers)
- Barracks: 300 stone + 150 wood + 50 iron
- Market: 200 wood + 100 gold
- Tower: 400 stone + 100 wood
- Wonder: 5,000+ mixed (varies by design)

**Unit Costs**

- Villager: 50 food
- Militia: 60 food + 20 wood
- Infantry: 100 food + 50 iron
- Archer: 80 food + 40 wood
- Cavalry: 150 food + 80 iron
- Siege Crew: 100 food + 50 wood

**Upkeep**

- Villager: 0.2 food/min
- Military: 0.4 food/min
- Commander (if alive): 1.0 food/min
- Elite Units: 0.8 food/min

## Combat Balance

### Unit Stats

| Unit Type | HP | Damage | Armor | Speed | Range |
|-----------|----|----|-------|-------|-------|
| Villager | 50 | 5 | 0 | 1.0 | Melee |
| Militia | 100 | 15 | 2 | 1.2 | Melee |
| Infantry | 150 | 25 | 5 | 1.0 | Melee |
| Archer | 80 | 20 | 1 | 1.1 | 8m |
| Cavalry | 200 | 35 | 3 | 2.0 | Melee |
| Siege Crew | 60 | 10 | 0 | 0.8 | Special |

### Commander Stats (Progressive)

**Base**
- HP: 300
- Damage: 30
- Armor: 10
- Speed: 1.5

**Fully Upgraded** (all masteries)
- HP: 600
- Damage: 50
- Armor: 25
- Speed: 1.8
- Special abilities unlocked

### Damage Calculations

**Basic Formula**
```
final_damage = base_damage × (1 - armor_reduction) × morale_modifier

armor_reduction = armor / (armor + 100)
```

**Morale Modifiers**
- Commander alive & nearby: ×1.2
- Commander dead: ×0.8
- Outnumbered 2:1: ×0.9
- Defending home claim: ×1.15
- Low food (<10 min): ×0.8
- High ground: ×1.1 (ranged only)

### Siege Balance

**Trebuchet**
- Build cost: 400 wood + 200 iron
- Reload time: 15 seconds
- Range: 50m
- Ammo capacity: 500 resource units
- Crew required: 3

**Catapult**
- Build cost: 300 wood + 100 iron
- Reload time: 10 seconds
- Range: 35m
- Ammo capacity: 300 resource units
- Crew required: 2

**Ram**
- Build cost: 250 wood + 150 iron
- Speed: 0.5
- Anti-gate damage: ×5
- Crew required: 4

## Defender's Advantage

### Protection Mechanisms

**Offline Shields**
- Newbie shield: 7 days (can't be attacked)
- Small alliance shield (<5 members): max 1 claim loss per window
- Garrison AI: -20% attack disadvantage vs human defense
- Structure HP regen: 1% per hour when not in combat

**Raid Windows**
- Defender sets 2 windows per day (2 hours each)
- Attacker must declare during window
- 30-minute preparation time after declaration
- Structures invulnerable outside windows

**Territory Depth**
- Core claims (near Town Center): 2× HP
- Outer claims: Standard HP
- Can only lose 1-2 outer claims per raid window

### Attacker's Challenge

**Raid Costs**
- Raid License: 100 gold + 50 iron
- Siege equipment: 300-400 resources each
- Ammo: Variable (depends on strategy)
- Troop losses: Average 30-50% casualties

**Risk vs Reward**
- Failed raid = massive resource loss
- Successful raid = 60-70% of building materials recovered
- Commander kill = 200 prestige + strategic advantage
- Territory gain = long-term resource access

## Progression Balance

### Age Advancement Costs

**Feudal Age**
- Requirements: Town Center + 2 Houses
- Research cost: 500 food + 300 stone
- Time: 5 minutes
- Unlocks: Barracks, Market, better tools

**Castle Age**
- Requirements: Feudal + Barracks + Market
- Research cost: 1,000 food + 800 stone + 200 gold
- Time: 10 minutes
- Unlocks: Advanced units, siege, better materials

**Imperial Age**
- Requirements: Castle + 2 military buildings
- Research cost: 2,000 food + 1,500 stone + 500 gold + 100 iron
- Time: 15 minutes
- Unlocks: Wonders, elite units, gunpowder

### Tech Tree Balance

**Military Techs**
- Blacksmith upgrades: +10% damage per tier (3 tiers)
- Armor upgrades: +1 armor per tier (3 tiers)
- Unit upgrades: Enable better unit types

**Economic Techs**
- Wheelbarrow: +25% carry capacity
- Irrigation: -25% farm growth time
- Mining upgrades: +15% gather rate per tier (2 tiers)

**Special Techs**
- Masonry: +15% building HP
- Engineering: +20% siege range
- Chemistry: Unlock gunpowder

### Blueprint Size Limits

**By Age**
- Feudal: Max 15×15×10m (10,000 voxels)
- Castle: Max 30×25×15m (50,000 voxels)
- Imperial: Max 50×40×25m (200,000 voxels)
- Wonder: Max 100×100×50m (1,000,000 voxels)

## Anti-Griefing Measures

### Resource Sink Mechanics

**Decay**
- Unvisited structures: -1% HP per day after 7 days idle
- Max decay: 60% HP (can't fully destroy)
- Abandoned (30+ days no login): Rebel takeover event

**Upkeep Costs**
- Territory claims: 50 resources/day per claim
- Military units: Food upkeep
- Siege equipment: Wood + rope maintenance
- Wonders: 500 resources/day

### Exploit Prevention

**Anti-Duplication**
- Server validates all resource additions
- Building placement checks for material payment
- Blueprint costs re-calculated server-side
- Trade limits (max 1000 resources per trade)

**Anti-Automation**
- Action rate limits (max 10 commands/second)
- Pattern detection (flag suspicious repetitive behavior)
- CAPTCHA for high-value actions (wonder construction)

**Anti-Trolling**
- Blueprint moderation (ban offensive shapes)
- Alliance kick cooldowns (prevent sabotage)
- War declaration cooldown (prevent spam)
- Team damage disabled (prevent friendly fire griefing)

## Prestige Balance

### Earning Rates

**Fast Earning** (Active Play)
- Combat: ~100-200 prestige/hour
- Building: ~50-100 prestige/hour
- Territory control: ~25 prestige/hour

**Slow Earning** (Passive)
- Wonder ownership: ~100 prestige/day
- Territory: ~10 prestige/day

**One-Time Bonuses**
- Win season: 10,000 prestige
- Build wonder: 1,000 prestige
- Featured blueprint: 500 prestige

### Spending Balance

**Cosmetics** (No gameplay impact)
- Commander skins: 3,000 prestige
- Beam colors: 1,000 prestige
- Building textures: 2,000 prestige
- Emotes: 250 prestige

**QoL Perks** (Capped)
- Starter cart (+100 wood/stone): 5,000 prestige
- +1 villager carry capacity: 3,000 prestige
- -10% blueprint validation time: 2,000 prestige

**Hard Caps on Power**
- Max efficiency bonus: +15%
- No direct combat bonuses
- No resource generation bonuses
- All QoL perks soft-capped per season

## Meta Strategies

### Expected Playstyles

**Turtle** (Defensive)
- Heavy fortifications (stone/obsidian)
- Underground bases
- Long-term resource accumulation
- Wonder victory focus

**Rush** (Aggressive)
- Fast feudal/castle age
- Early military pressure
- Deny enemy expansion
- Commander assassination attempts

**Boom** (Economic)
- Maximum villager count
- Control resource-rich territory
- Trade empire (emeralds)
- Overwhelm with production

**Hybrid** (Flexible)
- Balanced military + economy
- Adapt to enemy strategy
- Alliance-focused
- Opportunistic raiding

### Counter-Strategies

**vs Turtle**
- Long siege with explosive ammo
- Underground collapse attacks
- Economic blockade (deny resources)

**vs Rush**
- Strong early defense (militia spam)
- Walls + towers quickly
- Allied reinforcements
- Counter-attack when overextended

**vs Boom**
- Deny expansion (claim territory first)
- Raid workers (reduce efficiency)
- Form coalitions (multiple enemies)

**vs Hybrid**
- Specialize harder (out-boom or out-rush)
- Pick apart alliances (diplomacy)
- Target weaknesses (economy or military)

## Balance Tuning Methodology

### Data Collection

**Metrics to Track**
- Win rates by strategy
- Resource gather rates by material
- Average game length
- Most-used units/buildings
- Commander death rates
- Prestige earning distribution

**Community Feedback**
- Forum discussions
- In-game surveys
- Balance complaint reports
- Pro player feedback

### Iterative Updates

**Monthly Balance Patches**
- Adjust gather rates (±10% max)
- Tweak unit stats (HP, damage, cost)
- Modify tech costs/timings
- Fix exploits

**Seasonal Overhauls**
- Major mechanic changes
- New resources/units
- Meta shifts
- Community-voted changes

**A/B Testing**
- Test changes on 10% of shards
- Compare data vs control group
- Roll out if positive
- Revert if negative

## Victory Conditions Balance

### Prestige Victory

**Calculation**
```
prestige_score = 
  territory_points × 2 +
  combat_points × 3 +
  building_points × 1.5 +
  economy_points × 1 +
  wonder_points × 5
```

**Weights favor different playstyles**
- Combat players can win through war
- Builders can win through monuments
- Economists can win through trade/territory

### Wonder Victory

**Requirements**
- Build Wonder (5,000+ resources)
- Defend for 30 days
- Alliance can contribute

**Balance**
- Massive resource sink (delays military)
- Huge target (everyone attacks)
- High reward (5× prestige multiplier if successful)
- Rare (1-2 per season per shard)

### Elimination Victory

**Conditions**
- Destroy all enemy structures
- Kill commander (no respawn resources)
- Claim all territory

**Balance**
- Very difficult (defender's advantage)
- High prestige reward
- Creates epic stories
- Usually requires alliance

## Seasonal Meta Evolution

### Expected Patterns

**Early Seasons** (Months 1-3)
- Experimentation phase
- Diverse strategies
- Balance issues discovered
- Community learning

**Mid Seasons** (Months 4-8)
- Meta stabilizes
- Dominant strategies emerge
- Counter-strategies develop
- Balance patches active

**Late Seasons** (Months 9-12)
- Refined meta
- High-skill play
- Edge-case strategies viable
- Preparation for next season

### Preventing Stagnation

**Seasonal Modifiers** (Optional)
- "Diamond Rush" season: 2× diamond spawns
- "Flood Season": More water, rain events
- "Gunpowder Age": Reduced explosive costs
- "Builder's Paradise": Faster construction

**New Content Drops**
- New materials (quarterly)
- New units (seasonal)
- New mechanics (yearly)
- Community blueprints featured

---

*Balance is a journey, not a destination. Iterate, listen, adapt.*

