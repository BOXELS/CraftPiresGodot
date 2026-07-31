# CraftPires.com Game Design Document

## Vision Statement

CraftPires.com is a hybrid RTS + Minecraft-inspired "forever game" where players mine, build, and wage war in a persistent voxel world. Combining Age of Empires II's economy, The Settlers II's logistics, Empire Earth's tech progression, and Minecraft's creativity, CraftPires creates year-long seasons where civilizations rise, collapse, and leave permanent scars on the map.

---

## Core Philosophy

- **Resources ARE the game**: Everything is built from mined voxels, everything can be destroyed and reclaimed
- **Terrain tells the story**: Wars reshape the planet permanently - rivers redirected, mountains hollowed, tunnels collapsed
- **Commander as identity**: Your Commander unit is the leader of your civilization - mine, build, strategize
- **Unlimited peasants**: AoE II-style peasant system with housing capacity limits
- **Physical hauling**: Settlers II-style material delivery with visible supply chains
- **Team coordination**: 1 Commander + up to 9 human-controlled peasants per civilization
- **Emergent civilizations**: Every civ looks unique based on resources gathered and how they're used
- **Forever gameplay**: Year-long seasons with persistent worlds, revenge cycles, alliance drama
- **No prefabs**: Everything is voxel-based construction with physical material delivery

---

## Key Differentiators

1. **Unlimited peasant system** - AoE II-style economy with housing capacity, not 1-9 total peasants
2. **Fine-grain voxel terrain** - Organic, natural-looking terrain (NOT blocky Minecraft style) with randomized edges
3. **Physical material delivery** - Settlers II-style hauling, peasants carry materials to construction sites
4. **Resource warfare** - Trebuchets throw actual resources; destroyed buildings drop materials (60-70% recovery)
5. **Underground layer** - Dig bases, create tunnels, collapse enemy fortifications from below
6. **Material-based stats** - Diamond walls stronger than dirt; obsidian resists fire; physics-driven
7. **Persistent scars** - After a year, the map shows every war, mine, and monument ever created
8. **Team-based gameplay** - 1 Commander + up to 9 human peasants + unlimited AI peasants per civ
9. **Peasant cannon trolling** - Launch peasants as trebuchet ammunition for hilarious physics and sabotage
10. **Multi-shard world** - 50 civs per shard (500+ players), cross-shard travel for epic warfare
11. **No instant building** - All construction requires Settlers-style material hauling, no magical prefabs
12. **Tech progression system** - Empire Earth epochs + Civilization tech trees, resource-driven advancement
13. **Physics & creativity** - Water + dirt = mud traps, wind tunnels, gravity drops, endless experimentation
14. **24/7 gameplay** - AI automation keeps civs moving even when offline, no immunity shields

---

## Game Loop

**Gather → Build → Experiment → Laugh → Rebuild → Expand**

**The Voxel RTS Experience:**
1. Commander mines voxel clumps (wood, stone, rare ores) with beam mining
2. Peasants gather and physically carry materials to construction sites
3. Construct buildings in stages (foundation → walls → roof → complete)
4. Train units, establish defenses, research tech
5. Wage war using resource-based siege weapons
6. Mine enemy buildings for their materials (60-70% recovery)
7. Reshape terrain strategically (moats, traps, tunnels)
8. Year-long season with persistent world modifications

---

## Documentation Structure

### Development (repository)
- [**Development Guide**](./development.md) — Godot quick start, scenarios, agent workflow
- [**Godot Build Plan**](./godot-build-plan.md) — **NEW**: MVP-first phased plan for the from-scratch Godot 4.7 build
- [**Godot Rebuild Notes**](./web-rebuild-notes.md) — from-scratch Godot build log (reset July 2026)
- [**Controls & Shortcut Customization**](./controls-customization.md) — defaults (AoE2 → MC), remap + future DB

### Core Game Mechanics
- [**Game Mechanics Summary**](./game-mechanics-summary.md) - **NEW**: AoE II + Settlers II + Empire Earth + Minecraft integration
- [**Core Concepts**](./core-concepts.md) - Game philosophy and design pillars
- [**Peasant System**](./peasant-system.md) - **NEW**: AoE II-style unlimited peasants + co-op human control
- [**Commander System**](./commander-system.md) - The hero unit of your civilization
- [**Resource System**](./resource-system.md) - Materials, gathering, and economy

### Building & World
- [**Building & Construction**](./building-construction.md) - Settlers II-style physical hauling (NO PREFABS)
- [**Settlements, Territory & Roads**](./settlement-territory.md) - Keep+Tower claim radii, multi-Keep, roads, age gates
- [**Terrain & World**](./terrain-world.md) - Voxels, shards, underground, water physics
- [**Seasonal Structure**](./seasonal-structure.md) - Year-long seasons, shard structure, victory conditions

### Combat & Progression
- [**Warfare System**](./warfare-system.md) - Combat, siege, and resource weapons
- [**Tech Progression**](./tech-progression.md) - Empire Earth ages + Civilization tech trees
- [**Civilizations**](./civilizations.md) - AoE II packs; **Larpites** / **TechnoLarps**; custom names = `LARP` caps only (`zLARPs`, `LARPinaties`)

### Advanced Features
- [**Logistics Warfare**](./logistics-warfare.md) - **NEW**: Knights & Merchants-style supply chain warfare
- [**Physics & Creativity**](./physics-creativity.md) - Water, mud, gravity, fire interactions
- [**Customization Sandbox**](./customization-sandbox.md) - Aesthetic customization with realistic consequences
- [**Mentorship System**](./mentorship-system.md) - Advanced players protect and boost new players

### Economy & Community
- [**Crypto Economy**](./crypto-economy.md) - CPT tokens + NFT rare items worth real money
- [**Live Streaming**](./live-streaming.md) - Daily content, community engagement, epic moments
- [**Team System**](./team-system.md) - Co-op coordination, roles, voice chat

### Technical & Balance
- [**Technical Implementation Plan**](./technical-implementation-plan.md) - Voxel engine (Godot), networking, optimization
- [**Technical Architecture**](./technical-architecture.md) - Server model, persistence, scalability
- [**Layer Loading Optimization**](./layer-loading-optimization.md) - Heightmap + surface-layer voxel loading
- [**Multiplayer Design**](./multiplayer-design.md) - Authoritative multiplayer reference
- [**Balance & Design**](./balance-design.md) - Balance considerations and anti-griefing
- [**Quick Reference**](./quick-reference.md) - TL;DR of all systems

---

## Target Audience

- **RTS fans** who want deeper resource gameplay (AoE II lovers)
- **Settlers II fans** seeking strategic competition with logistics chains
- **Minecraft players** seeking strategic competition with physics creativity
- **Empire Earth players** who love long-term tech progression
- **"Forever game" enthusiasts** who enjoy year-long world persistence
- **Team players** who love co-op coordination and voice chat
- **Creative builders** who want to experiment with physics and aesthetics

---

## Inspirations

### Age of Empires II (1999)
- **Peasant/villager system**: Unlimited workers based on housing capacity
- **Resource economy**: Gather food, wood, stone, gold
- **Military training**: Convert peasants to soldiers
- **Tech tree**: Research upgrades at buildings
- **Hotkey control**: Efficient unit management

**What We Take:**
- Unlimited peasants (housing-limited)
- Resource gathering mechanics
- Military unit training
- Age advancement system
- Strategic hotkey control

### The Settlers II (1996)
- **Physical material hauling**: Workers carry resources visibly
- **Supply chain logistics**: Mines → storage → construction
- **Road networks**: Optimize transport efficiency
- **Visible construction phases**: Watch buildings grow
- **Worker AI**: Auto-task finding, efficient pathing

**What We Take:**
- Peasants physically carry voxel clumps
- Materials must be delivered to construction sites
- Roads increase transport speed
- Construction in visible stages
- Satisfying logistics chains

### Empire Earth (2001)
- **14 epochs**: Prehistoric → Nano Age
- **Age progression**: Unlocks new units/buildings/tech
- **Civilization bonuses**: Unique advantages per faction
- **Long-term strategy**: Plan across ages
- **Tech tree branching**: Choose specialization paths

**What We Take:**
- 3 Ages (Primitive, Metal, Gunpowder/Crystal)
- Resource-driven tech progression
- Commander upgrades tied to materials
- Strategic specialization choices
- Long-term seasonal strategy

### Minecraft (2009)
- **Voxel world manipulation**: Destructible terrain
- **Creative building**: Design unique structures
- **Material properties**: Different materials have different strengths
- **Physics interactions**: Water, lava, gravity, fire
- **Underground exploration**: Dig tunnels, create bases

**What We Take:**
- Voxel building (smaller scale, organic edges)
- Material-based crafting and construction
- Terrain modification and destruction
- Physics systems (water+dirt=mud)
- Creative expression within gameplay

---

## Scale & Scope

### Per Shard (512×512×256m world)

- **Up to 50 civilizations** maximum per shard
- **50 to 500+ total humans** (if each civ has 1-10 players)
  - **1 Commander** per civilization (strategic control)
  - **Up to 9 human peasants** per civilization (optional co-op)
  - **Unlimited AI peasants** per civilization (housing-limited, like AoE II)
- **Thousands of AI peasants** across all civs (each civ can have 50-200+ AI peasants)
- **Seamless terrain** (no loading screens within shard)
- **24/7 gameplay** (AI automation when players offline, no immunity shields)

### Multiple Shards (Linked Worlds)

- **Separate game instances** (reduce server load, prevent lag)
- **Named shards**: "Shard Alpha", "Shard Beta", "Shard Genesis"
- **Cross-shard travel**: Load into different shards to help allies or attack enemies
- **Shared reputation**: Prestige, achievements carry across shards
- **Different biomes**: Ice world, desert world, volcanic world, forest world
- **Independent seasons**: Each shard runs its own 365-day cycle

### Year-Long Seasons

- **365-day cycle** per shard
- **Persistent world**: All changes permanent until season end
- **Hall of Legends**: Best civs immortalized after season reset
- **Season reset**: New procedural generation, players start fresh
- **Carryover bonuses**: +10% starting resources per previous season win

---

## Core Gameplay Loop

### Early Game (First Hour)
1. **Commander spawns** with starting resources
2. **Place Town Center** (Settlers-style construction with material hauling)
3. **Train first peasants** (AoE II economy, 3 starting peasants)
4. **Gather wood and food** (survival priority)
5. **Build houses** (unlock population cap, like AoE II)
6. **Establish economy** (assign peasants to mining, lumber, farming)

### Mid Game (Hours 2-10)
1. **Age advancement** to Metal Age (Empire Earth progression)
2. **Military production** (barracks, training units from peasants)
3. **Territory expansion** (claim resource-rich areas)
4. **Trade and diplomacy** (markets, alliances)
5. **Tech research** (blacksmith upgrades, specialized buildings)
6. **First conflicts** (skirmishes over resources, border disputes)

### Late Game (Weeks to Months)
1. **Wonder construction** (massive voxel projects, alliance efforts)
2. **Advanced warfare** (siege weapons, coordinated attacks)
3. **Logistics chains** (supply chain warfare, Knights & Merchants complexity)
4. **Alliance politics** (betrayals, mega-battles)
5. **Terrain warfare** (collapse tunnels, flood valleys, mud traps)
6. **Season endgame** (prestige race, victory conditions)

---

## Technical Approach

### Voxel Engine
- **Fine-grain voxels**: 0.1m³ render scale (organic, natural appearance)
- **Chunk system**: 32×32×32 voxel chunks for efficient processing
- **Greedy meshing**: Combines adjacent voxels into optimized polygons (10-100× performance improvement)
- **LOD (Level of Detail)**: Distant chunks use simplified meshes
- **Client-side rendering**: Heavy computation on client, server validates actions

### Networking
- **Client-server model**: Server is authority, clients render and predict
- **Chunk-based updates**: Only send changed voxels (delta compression)
- **Run-length encoding**: Compress repeated voxels (32KB → 500 bytes for empty chunks)
- **Interest management**: Only send nearby chunk updates
- **20 TPS (50ms tick rate)**: Smooth real-time gameplay

### Physics Simulation
- **Client-side prediction**: Players see smooth movement without lag
- **Server validation**: Prevents cheating, authoritative state
- **Water flow**: Cellular automata, downward priority
- **Gravity**: Unsupported voxels fall (dirt, sand, gravel)
- **Fire spread**: 10% chance per adjacent flammable voxel
- **Collision**: Bounding box approach (not per-voxel)

### Recommended Stack
- **Game Engine**: Godot 4.7 (Forward+ renderer, Jolt Physics, GDScript) — see [`godot-build-plan.md`](./godot-build-plan.md)
- **Server**: Headless Godot dedicated servers (one per shard) + lightweight coordinator service
- **Database**: PostgreSQL (persistent storage) + Redis (in-memory cache); Supabase (Boxels project) for auth/saves
- **Networking**: Godot high-level multiplayer over ENet (UDP) for real-time; WebSocket fallback for future web exports

---

## Win Conditions

### Prestige Victory (Most Common)
- **Accumulate most prestige** across the season
- **Multiple paths**: Territory (×2), combat (×3), building (×1.5), economy (×1), wonder (×5)
- **Continuous scoring**: Leaderboard updates in real-time

### Wonder Victory (Most Prestigious)
- **Build Wonder** (5,000-50,000 materials, weeks to construct)
- **Defend for 30 days** (everyone attacks you)
- **Alliance can help** (team effort encouraged)
- **High prestige reward**: 5× multiplier if successful

### Elimination Victory (Most Dramatic)
- **Destroy all enemy structures** in your region
- **Kill all enemy Commanders** (force permanent exile)
- **Claim all territory** (no one else left)
- **Extremely rare**: Legendary status, 10,000+ prestige

---

## Co-Op Multiplayer Structure

### Solo Play
- **1 player** controls 1 Commander + unlimited AI peasants
- **Full strategic control** (like AoE II singleplayer)
- **AI automation** when offline

### Co-Op Team (2-10 Players)
- **1 Commander** (strategic control, beam mining, respawn)
- **Up to 9 human-controlled peasants** (each player = 1 peasant character)
- **Plus unlimited AI peasants** (controlled by Commander, like AoE II villagers)
- **Voice chat coordination** (real-time teamwork)
- **Role specialization**: Mining expert, builder, warrior, scout, farmer, engineer, diplomat, saboteur

**Example 10-Player Team:**
- Player 1: **Commander** (strategic overview, beam mining, coordination)
- Player 2: **Master Miner** (focuses on gathering rare materials)
- Player 3: **Head Builder** (manages construction projects)
- Player 4: **Military Captain** (leads army in battles)
- Player 5: **Scout** (explores, gathers intelligence)
- Player 6: **Farmer** (manages food economy)
- Player 7: **Engineer** (operates siege weapons)
- Player 8: **Diplomat** (handles alliances, trade)
- Player 9: **Defender** (manages walls, towers, defenses)
- Player 10: **Saboteur** (infiltrates enemy, plants traps)
- Plus 50-200 AI peasants doing basic gathering/building tasks

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
✅ **No prefabs** - Everything built from gathered voxels with visible construction
✅ **24/7 world** - AI automation, no immunity shields, real persistence

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
- ❌ Immunity shields (24/7 gameplay with AI automation instead)
- ❌ Limited peasants (unlimited like AoE II, not 1-9 total)

---

## Development Roadmap

### Phase 1: Core Engine (3-6 months)
- [ ] Voxel layer system in GDScript (heightmap + surface layer per 32×32 chunk; underground on demand)
- [ ] Chunk meshing via SurfaceTool/ArrayMesh (naive first, greedy meshing later)
- [ ] Collision via heightmap lookup + Jolt Physics for units; raycast picking
- [ ] A* pathfinding on the heightmap grid (AStar3D or custom flow fields)
- [ ] Commander beam mining mechanics
- [ ] See [`godot-build-plan.md`](./godot-build-plan.md) for the MVP-first breakdown

### Phase 2: Gameplay Systems (6-9 months)
- [ ] Peasant workforce (AoE II-style unlimited peasants)
- [ ] Physical material hauling (Settlers II-style)
- [ ] Building construction (voxel-based, staged building)
- [ ] Combat system (units, damage, siege weapons)
- [ ] Resource gathering and storage
- [ ] Save/load (single-player shard serialization)

### Phase 3: Advanced Features (9-12 months)
- [ ] Physics (water flow, gravity, fire spread)
- [ ] Age progression (Empire Earth-style 3 ages)
- [ ] Tech tree and upgrades
- [ ] Multiplayer co-op (10 humans per civ) — ENet dedicated server (headless Godot export)
- [ ] Cross-shard travel

### Phase 4: Polish & Scale (12-18 months)
- [ ] Performance optimization (LOD, chunk culling; move meshing to GDExtension/C++ if profiles demand)
- [ ] AI improvements (offline automation, smart pathing)
- [ ] UI/UX refinement
- [ ] Persistence via Supabase (boxels project, `cp_` tables); season system and Hall of Legends
- [ ] Live streaming integration

---

## Success Metrics

**Player Engagement:**
- Average session length: 2-4 hours
- Return rate: 60%+ after 7 days
- Season completion: 30%+ finish full year

**Community:**
- Concurrent players: 500+ per shard (5,000+ across all shards)
- Daily active civs: 200+ per shard
- Social shares: 100+ clips/day across platforms

**Monetization:**
- Cosmetic purchases: $5-20 per player per season
- Premium subscriptions: 10%+ conversion
- Sponsorships: Major gaming brands

---

*20 years in the making. Age of Empires meets The Settlers meets Minecraft. Let's build something legendary.*
