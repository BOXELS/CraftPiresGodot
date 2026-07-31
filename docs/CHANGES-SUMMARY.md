# Documentation Update Summary

This document summarizes all clarifications and corrections made to the CraftPires documentation based on your feedback.

---

## Major Clarifications

### 1. Peasant System (CRITICAL CORRECTION)

**BEFORE (Incorrect):**
- "1-9 Peasants total per civilization"
- "Peasants are limited to 1-9 human players"
- Confusion about peasants being players vs units

**AFTER (Correct):**
- **Unlimited AI peasants** per civilization (like Age of Empires II villagers)
- **Based on housing capacity** (houses provide +5 population each)
- **Up to 9 human-controlled peasants** (optional co-op, each human controls ONE peasant)
- **1 Commander** per civilization (strategic control of all AI peasants)
- **Total humans per civ**: 1 Commander + 0-9 human peasants = 1-10 humans
- **Total peasants per civ**: Potentially 50-200+ AI peasants (housing-limited)

**Created New Document:**
- [peasant-system.md](./peasant-system.md) - Comprehensive peasant mechanics

---

### 2. World Structure (CRITICAL CORRECTION)

**BEFORE (Incorrect):**
- "512×512m regions added daily"
- "50 active players per region (5 civilizations max)"
- "10,000+ players in queue"
- Confusion about single world vs multiple shards

**AFTER (Correct):**
- **Multiple separate shards** (not one growing world)
- **Each shard**: 512×512×256m separate game instance
- **Named shards**: "Shard Alpha", "Shard Beta", "Shard Genesis"
- **50 civilizations per shard** (NOT 50 players)
- **500+ potential players per shard** (if each civ has 10 humans)
- **Cross-shard travel**: Players can move between shards
- **New shards added** as funding/demand requires (not daily)
- **Independent seasons**: Each shard runs its own 365-day cycle

---

### 3. Building System (CRITICAL CORRECTION)

**BEFORE (Incorrect):**
- "Prefab buildings (RTS Simplicity) - instant placement"
- "Stronghold-style instant builds (mid game)"
- "Three-tiered system: Settlers/Stronghold/Knights & Merchants"
- Mix of prefab and custom voxel buildings

**AFTER (Correct):**
- **NO PREFABS EVER** - Everything is 100% voxel-based
- **Settlers II-style hauling for ALL buildings**
- **Physical material delivery**: Peasants must carry materials to construction sites
- **Construction in stages**: Foundation → Walls → Roof → Complete
- **Standard designs**: Community templates (still require hauling, not instant)
- **Knights & Merchants logistics**: Late-game supply chain warfare (not a building tier)

**Updated Documents:**
- [building-construction.md](./building-construction.md) - Removed all prefab references

---

### 4. Commander Respawn System (CORRECTED)

**BEFORE (Incorrect):**
- "Max 5 respawns per season"
- "1 Diamond respawn cost"
- "Scaling cost ×1.5 per respawn"

**AFTER (Correct):**
- **Unlimited respawns** (no maximum limit)
- **Base cost**: 500 food + 300 stone + 200 gold (no diamonds)
- **Time cost**: 5 minutes (peasants rebuild Commander)
- **Enemy capture**: Enemies can steal Commander voxel pieces
- **Sub-Commander**: Enemies can rebuild captured Commander as weaker version

---

### 5. Offline System (CORRECTED)

**BEFORE (Incorrect):**
- "Offline shields prevent attacks"
- "Raid windows (2 hours, twice per day)"
- "Newbie shield: 7 days"
- "Max 1 claim loss per window"

**AFTER (Correct):**
- **NO SHIELDS** (except optional newbie immunity)
- **24/7 gameplay**: World never stops, AI automation continues
- **Offline settings**: Customizable AI behavior when offline
- **Optional newbie immunity**: New players can start at distance from others
- **No forced protection**: Real persistence, real stakes

---

### 6. Tech Progression System (CLARIFIED)

**BEFORE (Somewhat vague):**
- "Empire Earth epochs + Civilization tech trees"
- "Resource-driven advancement"

**AFTER (More detailed):**
- **3 Ages** (not Empire Earth's 14):
  - Age 1: Primitive Age (wood/stone tools)
  - Age 2: Metal Age (iron weapons, siege warfare)
  - Age 3: Gunpowder/Crystal Age (explosives, advanced materials)
- **Age-specific tech trees**: Different upgrades per age
- **Commander upgrades**: Material mastery (Iron, Diamond, Emerald, Obsidian)
- **Resource-gated**: Mining specific materials unlocks technologies

---

## New Documents Created

### 1. [game-mechanics-summary.md](./game-mechanics-summary.md)
**Purpose**: Comprehensive integration of all four game inspirations

**Content:**
- How AoE II mechanics work in CraftPires
- How Settlers II logistics work in CraftPires
- How Empire Earth progression works in CraftPires
- How Minecraft creativity works in CraftPires
- The hybrid formula that combines all four
- Core gameplay loop with specific examples

---

### 2. [technical-implementation-plan.md](./technical-implementation-plan.md)
**Purpose**: Detailed technical architecture and voxel engine design

**Content:**
- Voxel engine architecture (chunk system, greedy meshing)
- Network optimization (delta updates, RLE compression)
- Physics simulation (water, gravity, fire, collision)
- Client-server model (prediction, validation)
- AI pathfinding (A* algorithm)
- Database schema (PostgreSQL + Redis)
- Performance targets (60 FPS, 20 TPS, <100ms latency)
- Development roadmap (4 phases, 12-18 months)
- Technology stack recommendations

---

### 3. [peasant-system.md](./peasant-system.md)
**Purpose**: Complete peasant mechanics documentation

**Content:**
- AI peasants (unlimited, housing-limited)
- Human peasants (0-9 co-op players)
- Peasant progression (4 stages: Primitive → Advanced)
- Economy system (AoE II-style gathering)
- Construction system (Settlers II-style hauling)
- Military conversion (peasant → soldier)
- AI behavior (auto-task finding, pathfinding)
- Co-op gameplay (team coordination, voice chat)
- Peasant trolling (cannon launches, comedy)

---

## Major Document Updates

### [core-concepts.md](./core-concepts.md)
**Changes:**
- Clarified peasant system (unlimited AI + optional 9 human)
- Clarified world structure (multiple shards, not one growing world)
- Removed prefab building mentions
- Added Settlers II building system details
- Clarified 24/7 gameplay with AI automation

---

### [commander-system.md](./commander-system.md)
**Changes:**
- Unlimited respawns (removed max 5 limit)
- Variable respawn cost (removed 1 diamond cost)
- Enemy capture mechanics (Sub-Commander system)
- Respawn process details (5 minutes, peasants rebuild)
- Strategic importance clarified

---

### [building-construction.md](./building-construction.md)
**Major Overhaul:**
- **Removed ALL prefab mentions**
- Added Settlers II physical hauling system
- Detailed material transport process (gather → carry → build)
- Construction phases (foundation → walls → roof → complete)
- Build speed calculations with multiple workers
- Transport efficiency (roads, carts, hovercrafts)
- Logistics strategies (centralized vs distributed storage)

---

### [terrain-world.md](./terrain-world.md)
**Changes:**
- Clarified shard system (separate game instances)
- Cross-shard travel mechanics
- Shard dimensions (512×512×256m)
- Why multiple shards (performance, choice, different biomes)
- Each shard = independent season

---

### [seasonal-structure.md](./seasonal-structure.md)
**Changes:**
- Clarified shard-season relationship (each shard = one season)
- Multiple shards running simultaneously
- Season phases (4 phases over 12 months)
- Victory conditions details
- Season reset process
- Hall of Legends archives

---

### [README.md](./README.md)
**Complete Rewrite:**
- Reflects all clarifications
- Properly describes AoE II + Settlers II + Empire Earth + Minecraft
- Correct peasant system description
- Correct world structure (shards)
- No prefab mentions
- Links to all new documents

---

## Concepts Removed/Deprecated

### ❌ Prefab Buildings
- No instant building placement
- No Stronghold-style mid-game mechanics
- Everything is voxel-based with physical hauling

### ❌ Three-Tiered Building System
- Confused mixing of Settlers/Stronghold/Knights & Merchants
- Replaced with single system (Settlers-style) + logistics warfare (K&M)

### ❌ Limited Peasants (1-9 total)
- Completely wrong understanding
- Replaced with unlimited AI peasants (housing-limited) + optional 9 human co-op

### ❌ Single Growing World
- World doesn't expand daily
- Multiple separate shards instead

### ❌ 50 Active Players Per Region
- Incorrect scale
- 50 civilizations per shard (500+ potential players)

### ❌ Offline Shields/Raid Windows
- No immunity mechanics
- 24/7 gameplay with AI automation

### ❌ Max 5 Commander Respawns
- Unlimited respawns
- No artificial limit

### ❌ 1 Diamond Respawn Cost
- Variable cost (food, stone, gold)
- No specific diamond requirement

---

## Key Terminology Clarifications

### Peasant (Two Meanings)
1. **AI Peasants**: Worker units (like AoE II villagers), unlimited quantity, Commander-controlled
2. **Human Peasants**: Player characters (up to 9 per civ), each human controls ONE peasant

### Shard
- **Separate game instance**: 512×512×256m world
- **50 civilizations max**: Performance limit
- **Named worlds**: "Shard Alpha", "Shard Beta"
- **Cross-shard travel**: Can move between shards

### Commander
- **1 per civilization**: Strategic leader
- **Controls AI peasants**: Like AoE II player controls villagers
- **Beam mining**: 2× gathering speed
- **Can die**: Respawn with resources + time
- **Co-op leader**: Coordinates up to 9 human peasants

### Construction
- **Always voxel-based**: No prefabs, no instant building
- **Physical hauling**: Settlers II-style material delivery
- **Staged building**: Foundation → Walls → Roof → Complete
- **Material requirements**: Bill of materials calculated from voxels

---

## Research References Added

### Age of Empires II (1999)
- Villager system (unlimited, housing-limited)
- Resource gathering mechanics
- Tech tree and age advancement
- Hotkey control and management

### The Settlers II (1996)
- Physical resource hauling
- Supply chain logistics
- Road networks
- Visible construction phases
- Worker AI and auto-task finding

### Empire Earth (2001)
- Epoch progression (14 ages)
- Tech tree branching
- Long-term strategy
- Civilization bonuses

### Minecraft (2009)
- Voxel world manipulation
- Material properties
- Physics interactions
- Creative expression

---

## Technical Details Added

### Voxel Engine
- Chunk system (32×32×32 voxels)
- Greedy meshing (10-100× optimization)
- LOD (Level of Detail)
- Client-side rendering

### Networking
- Delta compression
- Run-length encoding
- Interest management
- 20 TPS tick rate

### Physics
- Water flow (cellular automata)
- Gravity (unsupported voxels fall)
- Fire spread (10% chance per adjacent)
- Collision (bounding box, not per-voxel)

### Performance Targets
- 60 FPS minimum
- <100ms latency
- 500+ players per shard
- <4GB RAM client-side

---

## Documentation Organization Improvements

### Before
- Information scattered across documents
- Redundant explanations
- Conflicting information
- Missing details

### After
- Clear hierarchy (Core → Advanced → Technical)
- Cross-references between documents
- Consistent terminology
- Comprehensive coverage

### New Document Structure
```
Core Mechanics:
├── game-mechanics-summary.md (NEW - integration overview)
├── core-concepts.md (updated)
├── peasant-system.md (NEW - complete peasant docs)
├── commander-system.md (updated)
└── resource-system.md

Building & World:
├── building-construction.md (major overhaul)
├── terrain-world.md (updated)
└── seasonal-structure.md (updated)

Technical:
└── technical-implementation-plan.md (NEW - voxel engine)
```

---

## Questions Answered

### ✅ "Is it one world or multiple shards?"
**Answer**: Multiple separate shards, each 512×512×256m, cross-shard travel possible

### ✅ "Are peasants limited to 1-9 total?"
**Answer**: No! Unlimited AI peasants (housing-limited), plus optional 0-9 human co-op peasants

### ✅ "Are there prefab buildings?"
**Answer**: No! Everything is voxel-based with Settlers II-style physical hauling

### ✅ "How does the Commander respawn system work?"
**Answer**: Unlimited respawns, costs resources + time, enemies can capture pieces

### ✅ "Are there offline shields?"
**Answer**: No! 24/7 gameplay with AI automation, optional newbie immunity only

### ✅ "What's the three-tiered building system?"
**Answer**: Deprecated - single system (Settlers hauling) + logistics warfare (Knights & Merchants)

### ✅ "50 active players per region?"
**Answer**: No! 50 civilizations per shard (500+ potential players if each civ has 10 humans)

### ✅ "How do ages work?"
**Answer**: 3 Ages (Primitive, Metal, Gunpowder/Crystal) with resource-driven progression

---

## Remaining Action Items

### Clarification Needed
- **Crypto economy viability**: Legal/regulatory concerns, exploitation prevention
- **Rare item capture mechanics**: Exact mechanics for NFT warfare
- **Technical feasibility**: Can this scale actually work with current technology?
- **MVP scope**: What's the first playable version?

### Documents Still Need Review
- resource-system.md (probably okay, need to verify)
- warfare-system.md (probably okay, need to verify)
- crypto-economy.md (needs legal/regulatory section)
- balance-design.md (needs verification)

---

## Summary of Changes

**3 New Documents Created:**
1. game-mechanics-summary.md
2. technical-implementation-plan.md
3. peasant-system.md

**8 Documents Updated:**
1. core-concepts.md
2. commander-system.md
3. building-construction.md
4. terrain-world.md
5. seasonal-structure.md
6. README.md
7. (Plus minor updates to others)

**Major Corrections:**
- Peasant system (unlimited AI + optional 9 human)
- World structure (multiple shards, not one growing world)
- Building system (no prefabs, all Settlers-style hauling)
- Commander respawn (unlimited, not max 5)
- Offline system (24/7 AI, no shields)

**Deprecated Concepts:**
- Prefab buildings
- Three-tiered building system
- Limited peasants (1-9 total)
- Single growing world
- Offline shields/raid windows
- Max respawn limits

---

*All documentation now accurately reflects the AoE II + Settlers II + Empire Earth + Minecraft hybrid vision with voxel-based construction, unlimited peasants, multi-shard structure, and 24/7 persistent gameplay.*
