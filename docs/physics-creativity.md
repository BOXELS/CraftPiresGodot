# Physics & Creativity System

## Phased Physics Roadmap (confirmed 2026-07-05)

**The question: is it too early to do physics for the whole game?** Answer: too early to do it *all*, exactly the right time to lay the *foundations*. The voxel world, block trees, fragment physics, and building footprints we already have ARE the physics substrate — everything below builds on them incrementally, and each phase ships something playable. What we must do NOW is keep every new system compatible with the end-state rules (deterministic, ID-based, command-driven — see `multiplayer-design.md`), so nothing has to be rebuilt.

### Phase 0 — SHIPPED (the substrate)
- **Voxel terrain, every block gatherable** — commander beam already extracts any ground block with per-material gather times (`BLOCK_INFO`).
- **Block trees with fragment physics** — trees are cubes; felling turns each cube into a tumbling rigid fragment (gravity, bounce, settle). Logs lie where they fall and are harvested as piles.
- **Solid bodies** — buildings have hard footprints (nav + push-out); trees and boulders now have trunk-radius collision. Nothing walks through anything.
- **Commander tree-smack** — Ctrl+RMB sprint (stamina-limited); a sprinting commander that rams a tree knocks it FLYING (3× fragment velocity). Same charge sweeps peasants — they cartwheel through the air and land idle (carry dropped). Purposeful only: pathing and the harvest beam never trigger it. The wood still drops as a harvestable pile.

### Phase 1 — SHIPPED (gravity for the world itself)
- **Unsupported-block collapse**: when a voxel column is undermined, blocks above fall as fragments (reuse the tree fragment system) and land as gatherable piles. This is the seed of tunnel warfare. (`scripts/world/collapse.gd`, beam targets the clicked voxel not just column top.)
- **Peasant sprint parity + stamina UI polish** — Ctrl+RMB sprint already applied to all units; HUD shows stamina hints per unit type and turns red when low.
- **Falling damage / crush stubs** — falling fragments deal partial HP damage on impact (death/respawn deferred to warfare pass).
- **Unit step / climb (confirmed 2026-07-14):** walk edges ≤ **2** voxels are free (soft nav penalty only). Sheer faces **3…ageMax** are climbable but slow (no sprint; Age 1 max **6**, Age 2 **8**, Age 3 **10** — research can raise the table later). Steps taller than `climbMax` are **blocked** in flow-field solve and at seek/F-mode velocity (same slide pattern as walls). Dig a ramp to escape deep shafts; ladders / placeable stairs / MC block-place escape = later content. Close-range steer uses the same gate so units cannot cliff-teleport.

### Phase 2 — SHIPPED (structural integrity & undermining)
- **Support scan**: each building measures footprint columns vs `foundationTop`
  (set at place). Below **60%** support → structural HP drain; at **≤30%**
  (or 0 HP) the building **collapses** into tumbling rubble + loot piles
  (construction cost / delivered mats + depot stock). Keep takes damage but
  floors at 1 HP (no full Keep wipe in the prototype).
- **Event hook**: `CollapseManager.onTerrainEdited` dirties support so digs
  rescan promptly; light periodic scan as backup.
- **HUD**: support bar when <100%; activity badge when cracking.
- **Scenario**: `--scenario=undermine`.
- **Still deferred**: stone foundations raising the threshold; watchtower
  digger reveal (warfare / Age content).

### Phase 3 — Water (reroutable, bucket-carried) — design lock-in 2026-07-13

Two layers that share one cellular sim:

1. **Minecraft-style harvest** — any water cell can be bucketed (Toolsmith
   recipe) for farms/moats; carrying water uphill is still bucket-only.
2. **CraftPires Water Source blocks (rare veins)** — permanent spring voxels
   deep in the crust (biome mineral/water tables place them). Properties:
   - `waterType`: fresh | salt | hot_spring | (later variants)
   - `volume` / `maxHead`: how much flow budget the vein can sustain
     (small creek → river → lake/ocean fill). Deterministic per source id.
   - **Not portable** — cannot mine-pickup or relocate the source. Digging
     under it can drop its elevation (vein follows bedrock collapse rules);
     that is the only way it “moves,” and makes finds strategically valuable.
   - Flowing water away from the source is ordinary cellular water (level
     0–7) that can be rerouted by channels; cutting the bank drains downhill.

- **Cellular water sim** on the voxel grid: each water cell holds a level 0–7; water flows to lower neighbors on a fixed tick (deterministic, chunk-local, budgeted per frame). Removing a dirt bank drains a hillside lake downhill; digging a channel reroutes the river.
- **Buckets** (Toolsmith recipe): peasants carry water 1 bucket at a time for farms/moats — the *only* way to move water uphill.
- **Gravity interplay**: water + dug channels + Phase 2 collapse = moats, flooded tunnels, drowned cellars. Mud (water+dirt) slows units — first material interaction from the table below.
- Engineering note: this is the expensive one. Budget: cap active water cells, sleep settled regions, simulate only near players' view/activity. Must stay deterministic for multiplayer lockstep. Cap simultaneous **active sources** simulated per shard.
- **Until then (pre-P3):** non-walkable water columns are not diggable; piles snap to shore; Gather All / work seeks stall-bail instead of thrashing on the waterline. Underwater dig unlocks with cellular water. Decorative water plane remains until the cell sim ships.

### Phase 4 — Material interactions & contraptions
- The full combination table below (lava/obsidian, fire spread, wind) — each one gated on the Phase 3 cell-sim proving out performance.

### Ground rules (so we never rebuild)
1. All physics state lives in the voxel grid / fragment lists — no hidden scene-graph-only state.
2. Every mutation goes through a command/event (multiplayer boundary).
3. Fragments are *visual + loot*; gameplay truth is grid state and pile contents.
4. Fixed-tick, seeded randomness for anything that affects outcomes.

---

## 50% Serious / 50% Silly Unit Physics (Gemini → Godot prototype)

**Design goal:** units path and macro exactly like AoE2 (flow-field kinematic mode, protected
keyboard shortcuts), but heavy hits, explosions, and melee add deliberate comedy physics —
never at the cost of orders feeling wrong.

Gemini’s Unity `SillyUnitController` (NavMesh ↔ ragdoll) is implemented in **`scripts/units/silly_physics.gd`**
as three modes on our blend-shell characters (no per-limb Rigidbodies — hundreds of units stay cheap):

| Gemini concept | CraftPires web implementation | Status |
|----------------|------------------------------|--------|
| Kinematic / NavMesh RTS mode | Flow-field `seek()` + capsule separation + building slide | **Shipped** |
| Ragdoll on explosion/knockback | `tumble` task — arc + spin on procedural rig (`setAirborne`) | **Shipped** |
| `ApplyExplosiveForce(epicenter, force, upwardModifier)` | `Unit.applyExplosiveForce()` → `launchFromExplosion()` | **Shipped** (API ready for siege Phase 4) |
| Recovery coroutine → re-enable pathing | `recovering` task (~0.45s crouch get-up) → `idle` | **Shipped** |
| Active ragdoll melee wobble | `rig.combatWobble` — floppy arms during chop/build, feet planted | **Shipped (subtle)** |
| Commander sprint body-check | Same charge sweep as tree-smack; now also wildlife (`AnimalField.bodySlam` reuses `launchFromImpulse`/`tickTumble`) | **Shipped** |
| Simple colliders at scale | One `radius` capsule per unit; fragments reuse tree physics | **Shipped** |
| Upward modifier = comedy | `EXPLOSION_UPWARD_DEFAULT = 1.55`; tune per weapon | **Shipped** |
| Goofy audio | `audio.yeet()` launch + `audio.land()` clunk | **Shipped (synth stubs)** |

**What we deliberately do NOT do (yet):**
- Full bone ragdolls or mesh colliders per limb (CPU melts at TA scale).
- Silly physics during normal pathing or beam-mining (purposeful hits only).
- Unity/Three.js code is reference only — the live game is the Godot 4.7 project at repo root.

**Next laughs (when warfare lands):**
- Trebuchet peasant ammo (`warfare-system.md`) calls `applyExplosiveForce` with high `upwardModifier`.
- Melee hits apply small impulse tumble (not full ragdoll) unless crit.
- Optional `--scenario=yeet` + `bodyslam` regression net.
- **Free Play debug:** press **`Y`** at cursor to `applyExplosiveForce` (Shift = higher arc, Ctrl = harder blast); console `__game.debugYeet(x, y, force, upward)`.

---

## Overview

**CraftPires is a sandbox RTS of endless creativity** where players can build, break, and experiment with physics-based contraptions. Every voxel is usable, every combination creates emergent gameplay, and every failure becomes a hilarious story.

## The Physics Engine

### Material Interactions

**Basic Combinations:**
- **Water + Dirt = Mud** - Slows units, creates sinkholes, temporary but effective
- **Lava + Water = Obsidian** - Creates permanent barriers, requires careful timing
- **Sand + Wood = Flammable** - Quick but dangerous defenses
- **Stone + Iron = Reinforced** - Strong but expensive structures

**Advanced Combinations:**
- **Diamond + Emerald = Crystal** - Glowing, beautiful, expensive
- **Coal + Sulfur + Flint = Gunpowder** - Explosive, dangerous, powerful
- **Clay + Water = Pottery** - Moldable, decorative, functional
- **Gold + Silver = Alloy** - Conductive, valuable, unique properties

### Environmental Physics

**Water Physics:**
- **Flow dynamics** - Water follows gravity and terrain
- **Pressure systems** - Dams create pressure, can burst
- **Flooding mechanics** - Water fills low areas, can drown units
- **Irrigation** - Controlled water flow for farming

**Wind Physics:**
- **Wind tunnels** - Channel wind to slow or speed up units
- **Windmills** - Generate power from wind direction
- **Sandstorms** - Wind + sand creates visibility and movement penalties
- **Flying debris** - Strong winds can throw lightweight materials

**Gravity Physics:**
- **Falling objects** - Boulders, debris, and structures can fall
- **Structural integrity** - Buildings need support or they collapse
- **Avalanches** - Unstable terrain can slide down slopes
- **Crushing damage** - Heavy objects deal massive damage when dropped

**Fire Physics:**
- **Spread patterns** - Fire spreads based on material flammability
- **Heat transfer** - Hot materials can ignite nearby flammable items
- **Smoke effects** - Fire creates visibility and breathing penalties
- **Ash and soot** - Fire leaves behind materials that can be collected

## Creative Contraptions

### Defensive Contraptions

**Mud Traps:**
- **Setup**: Dig pit, fill with water + dirt
- **Effect**: Units sink and slow down
- **Maintenance**: Requires regular refilling
- **Hilarious failure**: Can flood your own base if not careful

**Obsidian Barriers:**
- **Setup**: Channel lava into water source
- **Effect**: Creates permanent black barriers
- **Risk**: Can trap your own units if poorly planned
- **Strategy**: Use for permanent defensive lines

**Wind Tunnels:**
- **Setup**: Build walls to channel wind
- **Effect**: Slow enemy approach, speed up your units
- **Maintenance**: Wind direction changes, need adjustable design
- **Creative use**: Can power windmills for energy

**Gravity Drops:**
- **Setup**: Build platforms above enemy paths
- **Effect**: Drop boulders, debris, or even peasants
- **Timing**: Requires careful coordination
- **Hilarious potential**: Can accidentally crush your own units

### Offensive Contraptions

**Flaming Trebuchets:**
- **Setup**: Load trebuchet with flammable materials
- **Effect**: Fire spreads on impact
- **Risk**: Can burn down your own structures
- **Strategy**: Use against wooden defenses

**Water Cannons:**
- **Setup**: Channel water through narrow openings
- **Effect**: Push enemies off cliffs or into traps
- **Power**: Requires water pressure and elevation
- **Creative use**: Can create artificial rivers

**Sandstorm Generators:**
- **Setup**: Wind tunnels + sand collection
- **Effect**: Reduce visibility and movement
- **Duration**: Limited by sand supply
- **Tactical**: Use to cover approach or retreat

**Lava Channels:**
- **Setup**: Direct lava flow toward enemy
- **Effect**: Devastating but slow-moving
- **Risk**: Can destroy everything in path
- **Strategy**: Use for area denial

### Utility Contraptions

**Water Wheels:**
- **Setup**: Water flow + rotating mechanism
- **Effect**: Generate power for automated systems
- **Efficiency**: Depends on water flow rate
- **Maintenance**: Requires regular cleaning

**Mining Contraptions:**
- **Setup**: Gravity + collection systems
- **Effect**: Automate resource gathering
- **Materials**: Use different materials for different resources
- **Efficiency**: Can be more efficient than manual mining

**Transport Systems:**
- **Setup**: Rails, carts, and gravity
- **Effect**: Move resources automatically
- **Speed**: Depends on slope and materials
- **Maintenance**: Requires regular repairs

**Communication Systems:**
- **Setup**: Signal fires, bells, or flags
- **Effect**: Coordinate with allies
- **Range**: Limited by visibility and sound
- **Tactical**: Use for warnings or coordination

## The Laugh Factor

### Hilarious Failure Scenarios

**Mud Trap Disasters:**
- *"Player builds mud trap, forgets to drain it, floods own base"*
- *"Enemy walks around mud trap, player's own units fall in"*
- *"Mud trap works too well, traps player's own army"*

**Fire Mishaps:**
- *"Player lights signal fire, ignites own wooden fortress"*
- *"Flaming trebuchet backfires, burns down own walls"*
- *"Player tries to create obsidian, lava flows into own base"*

**Gravity Accidents:**
- *"Player builds gravity drop, accidentally crushes own peasants"*
- *"Boulder falls off platform, rolls into own town"*
- *"Player tries to drop water on enemy, floods own base"*

**Wind Tunnel Failures:**
- *"Player builds wind tunnel, wind changes direction, slows own units"*
- *"Windmill spins too fast, throws off debris"*
- *"Sandstorm generator creates permanent sandstorm in own base"*

### Epic Success Stories

**Creative Solutions:**
- *"Player uses water + dirt to create moat around entire base"*
- *"Wind tunnel system powers entire mining operation"*
- *"Gravity drop system creates automated defense"*

**Tactical Brilliance:**
- *"Player redirects river to flood enemy base"*
- *"Lava channel creates permanent barrier"*
- *"Sandstorm covers entire battlefield"*

**Engineering Marvels:**
- *"Multi-story water wheel system"*
- *"Complex transport network using gravity"*
- *"Automated defense system using physics"*

## Resource Management for Creativity

### Material Properties

**Dirt:**
- **Abundance**: Very common
- **Uses**: Basic construction, mud traps
- **Durability**: Low, washes away
- **Cost**: Free, but requires water

**Stone:**
- **Abundance**: Common
- **Uses**: Strong structures, boulders
- **Durability**: High, permanent
- **Cost**: Moderate, requires mining

**Water:**
- **Abundance**: Varies by location
- **Uses**: Mud, irrigation, power
- **Durability**: Flows away
- **Cost**: Free, but requires management

**Lava:**
- **Abundance**: Rare, volcanic areas
- **Uses**: Obsidian, area denial
- **Durability**: Permanent when cooled
- **Cost**: High, dangerous to obtain

**Sand:**
- **Abundance**: Desert areas
- **Uses**: Sandstorms, glass
- **Durability**: Blows away
- **Cost**: Low, but requires wind

### Creative Resource Strategies

**Early Game:**
- **Focus on dirt and water** - Cheap mud traps
- **Basic wind systems** - Simple but effective
- **Wooden contraptions** - Quick and disposable

**Mid Game:**
- **Stone and iron** - More durable structures
- **Complex water systems** - Irrigation and power
- **Fire-based weapons** - Flaming trebuchets

**Late Game:**
- **Rare materials** - Diamond and emerald contraptions
- **Advanced physics** - Complex multi-material systems
- **Automated systems** - Self-maintaining contraptions

## Technical Implementation

### Physics Engine Requirements

```typescript
interface PhysicsMaterial {
  id: string;
  name: string;
  density: number;
  flammability: number;
  conductivity: number;
  viscosity: number;
  meltingPoint: number;
  freezingPoint: number;
  interactions: MaterialInteraction[];
}

interface MaterialInteraction {
  material1: string;
  material2: string;
  result: string;
  conditions: InteractionCondition[];
  effects: PhysicsEffect[];
}

interface PhysicsEffect {
  type: 'damage' | 'movement' | 'visibility' | 'durability';
  value: number;
  duration: number;
  area: number;
}
```

### Contraption System

```typescript
interface Contraption {
  id: string;
  name: string;
  materials: MaterialMap;
  physics: PhysicsProperties;
  effects: ContraptionEffect[];
  maintenance: MaintenanceRequirements;
  failureChance: number;
}

interface ContraptionEffect {
  type: 'defensive' | 'offensive' | 'utility' | 'transport';
  target: 'enemy' | 'ally' | 'neutral' | 'self';
  effect: PhysicsEffect;
  range: number;
  duration: number;
}
```

### Creative Tools

```typescript
interface CreativeTool {
  id: string;
  name: string;
  materials: MaterialMap;
  physics: PhysicsProperties;
  effects: CreativeEffect[];
  maintenance: MaintenanceRequirements;
  failureChance: number;
}

interface CreativeEffect {
  type: 'building' | 'destruction' | 'modification' | 'creation';
  target: 'terrain' | 'structure' | 'unit' | 'resource';
  effect: PhysicsEffect;
  range: number;
  duration: number;
}
```

## The Experience

### For Creators

**Satisfaction:**
- **Endless experimentation** - Try new combinations
- **Hilarious failures** - Learn from mistakes
- **Epic successes** - Create amazing contraptions
- **Social sharing** - Show off creations

**Challenges:**
- **Resource management** - Balance creativity with cost
- **Physics understanding** - Learn how materials interact
- **Maintenance** - Keep contraptions working
- **Risk assessment** - Avoid catastrophic failures

### For Viewers

**Entertainment:**
- **Hilarious failures** - Watch epic disasters
- **Creative solutions** - See amazing contraptions
- **Physics experiments** - Learn about material interactions
- **Social sharing** - Discuss and share creations

**Community:**
- **Contraption contests** - Compete for best designs
- **Physics education** - Learn about material properties
- **Creative inspiration** - Get ideas for own contraptions
- **Failure stories** - Share hilarious disasters

### For Streamers

**Content Creation:**
- **Physics experiments** - Test material combinations
- **Contraption building** - Create amazing structures
- **Failure moments** - Capture hilarious disasters
- **Success stories** - Show off amazing creations

**Engagement:**
- **Viewer participation** - Chat suggests experiments
- **Contraption building** - Build with community input
- **Physics education** - Teach about material interactions
- **Creative challenges** - Compete with viewers

---

## The Vision

**This creates a world where:**
- **Every material has properties** - Physics-based interactions
- **Every combination creates possibilities** - Endless experimentation
- **Every failure is hilarious** - Comedy from disasters
- **Every success is amazing** - Pride in creations
- **Every contraption tells a story** - Unique player experiences

---

*From mud traps to diamond contraptions. From hilarious failures to epic successes. Every player's creative journey is unique, shaped by physics, materials, and imagination.*
