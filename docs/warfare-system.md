# Warfare System

## Core Principle: Resources ARE Weapons

Unlike traditional RTS games where ammo is abstract, in CraftPires everything you throw at enemies is a real resource with strategic value.

## Siege Weapons

### Trebuchets & Catapults

**Universal Ammunition System**
- Can load **any** resource clump into siege weapons
- Different materials = different effects
- Strategic choice: use resources to attack or defend?

### Ammunition Types & Effects

| Ammo Type | Damage | Special Effect | Cost Efficiency |
|-----------|--------|----------------|-----------------|
| **Dirt** | Low | Messy splash, terrain fill | Very cheap, spammable |
| **Stone** | High | Anti-structure, wall breaker | Medium cost, effective |
| **Iron** | Very High | Armor penetration | Expensive, precise |
| **Wood** | Medium | Fire starter (if ignited) | Cheap, conditional |
| **Coal** | Medium | Burns on impact, area fire | Medium, tactical |
| **Sandbags** | Very Low | Fills moats/traps, blocks paths | Cheap, utility |
| **Gunpowder Bundle** | Explosive | AoE damage, structure collapse | Very expensive |
| **Diamond** | Extreme | Massive single-target damage | Extremely rare |

### Special Ammunition

**Gunpowder Weapons**
- **Recipe**: Flint + Coal + Sulfur (rare)
- **Bombs/Grenados**: Throwable explosives
- **Explosive Shot**: Trebuchet ammo with AoE
- **Musket Balls**: Late-game ranged units
- **Cannon Charges**: Siege cannons

**Combination Shots**
- **Fortified Mortar** (Stone + Clay + Coal): +15% siege damage
- **Fire Bundle** (Wood + Coal): Ignites structures
- **Obsidian Shot**: Armor-piercing, anti-gate

### The Peasant Cannon 💀

**The Ultimate Troll Move:**
- **Yes, you can launch peasants as ammunition**
- **Peasant physics** - They fly through the air, screaming
- **Survival chance** - 5% (primitive), 15% (advanced)
- **95% death rate** - Most peasants die on impact
- **Resource cost** - 50 food + training cost per peasant

**Peasant Ammunition Types:**

| Peasant Stage | Survival Chance | Sabotage Chance | Damage | Special Effects |
|---------------|-----------------|-----------------|--------|-----------------|
| **Primitive** | 5% | 10% | Low | Screaming, flailing, wooden tools |
| **Road-Building** | 8% | 15% | Medium | Iron tools, better aim |
| **Wheel-Discovering** | 12% | 20% | High | Steel tools, cart fragments |
| **Advanced** | 15% | 25% | Very High | Diamond tools, hovercraft parts |

**Hilarious Scenarios:**
- *"Advanced player launches 50 primitive peasants at enemy fortress"*
- *"Peasants fly through the air screaming, most die on impact"*
- *"One peasant survives, becomes saboteur, starts destroying from inside"*
- *"Viewers donate resources to fund more peasant launches"*

**Strategic Value:**
- **Psychological warfare** - Demoralizing to see peasants flying at you
- **Sabotage potential** - Surviving peasants can cause chaos
- **Resource drain** - Expensive but hilarious
- **Streaming gold** - Epic content for viewers

## Building Destruction & Recovery

### Physical Resource Banking

Buildings store their construction materials physically:

**Town Center** (800 Stone + 200 Wood)
- When destroyed → drops 560 Stone + 140 Wood (70% recovery)
- Attackers can mine the rubble
- Defenders can reclaim if they recapture

**Diamond-Plated Wall** (1000 Stone + 50 Diamond)
- Destroyed → drops 700 Stone + 35 Diamond
- Makes rich targets incredibly valuable
- Creates "resource wars" over ruins

### Recovery Mechanics

**Material Loss Rate**: 30-40% lost on destruction
- Prevents infinite recycling
- Makes war economically costly
- Rewards successful raids

**Collection**
- Rubble drops as collectible clumps
- Must be manually gathered by workers
- Can be stolen during battle
- Valuable ruins become contested zones

## Terrain Warfare

### Strategic Manipulation

**Moats**
- Dig trenches around fortifications
- Fill with water from redirected rivers
- Can be filled in by sandbag siege shots
- Counter: dirt bombardment to create bridges

**Underground Collapse**
- Tunnel beneath enemy walls
- Remove support beams
- Trigger controlled cave-in
- Drops entire structures into the earth

**Water Traps**
- Dam rivers, create cisterns
- Breach during battle to flood areas
- Drown enemy troops
- Destroy farmland

**Berms & Earthworks**
- Pile dirt/stone into defensive mounds
- Create high ground advantage
- Built from bombardment fill-in or manual construction

### Fire & Flood

**Fire Warfare**
- Wood structures burn easily
- Coal + Flint creates lasting fires
- Obsidian structures resist fire
- Can spread to forests (environmental hazard)

**Flood Warfare**
- Redirect rivers through enemy territory
- Collapse underground cisterns
- Sink armies in mud/water
- Destroy crop fields

## Unit Combat

### Basic Units
- **Villagers**: 0.5× combat power, primarily gather/build
- **Militia**: Cheap early defense
- **Infantry**: Main battle line
- **Archers**: Ranged, effective vs units
- **Cavalry**: Fast, flanking
- **Siege Crews**: Operate trebuchets, catapults, rams

### Material Equipment Bonuses

**Weapons**
- Wood: Basic, cheap
- Iron: +30% damage
- Diamond-tipped: +60% damage, armor penetration

**Armor**
- Leather: Light, fast
- Iron: Medium, balanced
- Diamond-plated: Heavy, slow, high protection
- Obsidian-trimmed: Fire resistance

### Morale & Command

**Morale Factors**
- Commander alive & nearby: +20%
- Commander dead: -20%
- Outnumbered: -10%
- Defending home: +15%
- Low food: -20%

**Command Bonuses**
- Commander aura: +10% effectiveness (stacks with morale)
- Elite units: Immune to morale penalties
- Banner placement: +5% in radius

## War Declaration System

### Preventing Griefing

**Raid Windows**
- Each claim has 2 daily raid windows (owner-configured)
- Each window = 2 hours
- Attacker must declare war during window
- Defender receives notification (in-game + email/push)

**Raid License**
- Cost: 100 Gold + 50 Iron (prevents spam)
- Declares war on specific claim(s)
- Valid for one window
- Expensive enough to require commitment

### Offline Defense

**Garrison AI**
- Pre-configured loadout (X archers, Y infantry, Z cavalry)
- Follows playbooks: Turtle, Skirmish, Sally, Firebreak
- Upgradeable via tech tree
- Executes automation rules

**Automation Rules** (JSON DSL)
```json
{
  "rules": [
    {
      "when": "WALL_HP_UNDER:0.6",
      "do": ["DEPLOY_REPAIR_CREWS", "ENABLE_FIRE_ARROWS"]
    },
    {
      "when": "GATE_BREACH",
      "do": ["RELEASE_CAVALRY_RESERVE", "FOCUS_FIRE:RAMS"]
    }
  ]
}
```

**Protection Limits**
- Max 1-2 outer claims destroyable per window when offline
- Prevents total wipeout at 3am
- Core base has stronger protection

## Advanced Siege Tech

### Late-Game Weapons

**Cannons** (Gunpowder + Iron)
- Direct fire, high accuracy
- Anti-structure specialists
- Ammo: gunpowder charges + iron balls

**Siege Towers** (Wood + Iron)
- Mobile, allows wall scaling
- Vulnerable to fire
- Requires crew

**Battering Rams** (Wood + Iron core)
- Anti-gate specialists
- Slow, must be protected
- Massive structure damage

**Ballistas** (Wood + Iron)
- Anti-personnel
- Long range
- Can target commanders

### Siege Upgrades

**Engineering Techs**
- Better trajectory (longer range)
- Faster reload
- Increased payload capacity
- Accuracy improvements

## Resource-Themed Tactics

### Diamond Kingdom Warfare
- Expensive, devastating shots
- Quality over quantity
- Each shot counts
- Defensive focus (too valuable to waste)

### Dirt Horde Warfare
- Spam cheap dirt shots
- Overwhelm with volume
- Fill moats, block paths
- Zerg rush tactics

### Coal/Iron Industry
- Fire weapons primary
- Area denial through flames
- Siege specialists
- Industrial bombardment

### Water Civilization
- Environmental manipulation
- Flood traps
- Moat defense
- River redirection

### Emerald Traders
- Economic warfare
- Bribe enemy units
- Hire mercenaries
- Trade embargoes

## Balance Mechanics

### Ammo Weight System
- Trebuchets have max capacity
- Can't spam infinite giant rocks
- Requires logistics trains
- Supply lines become targets

### Siege Upkeep
- Trebuchets need wood + rope maintenance
- Prevents free spam
- Creates economic drain during war
- Must commit resources to sustain siege

### Material Efficiency
- **Dirt**: 0.1 damage per resource
- **Stone**: 0.5 damage per resource  
- **Iron**: 1.0 damage per resource
- **Diamond**: 3.0 damage per resource
- **Gunpowder**: 2.5 damage + AoE

### Damage Caps
- Structure invulnerability during non-window hours
- Heavy damage only during declared windows
- Offline shields for small groups (< 5 members)
- Progressive destruction (can't one-shot wonders)

## Victory Conditions

### Elimination
- Destroy all enemy structures
- Kill their commander (no resources to respawn)
- Claim their territory

### Domination
- Control 60% of map territory
- Maintain for 7 days
- Triggers prestige victory

### Wonder Victory
- Build and defend Wonder for 30 days
- Massive resource investment
- Becomes primary target for all enemies

### Seasonal Victory
- Highest prestige at season end
- Based on: territory, monuments, wealth, victories
- Archived in Hall of Legends

## War Stories (Intended Gameplay)

**The Dirt Avalanche**
> A poor civ with only dirt mounds redirects a river, then bombards the dam with stone shots. The resulting flood carries thousands of dirt clumps into enemy farmland, burying it under meters of mud.

**The Diamond Heist**
> Raiders carefully siege a diamond-plated gate, recover 35 diamonds from rubble, and retreat before reinforcements arrive. They've just funded their entire next age.

**The Collapse**
> An alliance spends weeks tunneling under an enemy capital, placing wood support beams. During the climactic battle, they ignite the beams, collapsing the entire city into the earth.

**The Peasant Swarm**
> In a desperate last stand, a dying civ launches 100 peasants from trebuchets. 5 survive and sabotage the enemy smelter, buying time for an ally to arrive.

---

*War in CraftPires isn't just about destruction—it's about resource acquisition, terrain control, and making every shot count.*

