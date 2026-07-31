# Technical Architecture

## High-Level Design

### Core Principles

1. **Authoritative Server** - All game logic server-side, clients are view-only
2. **Deterministic Tick** - Fixed timestep for consistent simulation
3. **Event Sourcing** - All actions logged for replay/recovery
4. **Regional Partitioning** - World divided into independent server regions
5. **Scalable by Design** - Support 365 concurrent shards

## Technology Stack (Chosen: Godot 4.7)

> **Decision:** The game is built from scratch in **Godot 4.7** (GDScript). The earlier
> Three.js web prototype and Unity 6 prototype were evaluated and retired — see
> `docs/web-rebuild-notes.md` (reset as the Godot build log; its header summarizes the
> old prototypes' history and where the old log entries survive).

**Client**
- **Godot 4.7** with the **Forward+** renderer (already set in `project.godot`)
- **GDScript** for all gameplay code (evaluate C#/GDExtension only if profiling demands it)
- Top-down RTS camera with freecam for editor
- `MultiMeshInstance3D` / instanced rendering for voxel builds and units
- `SurfaceTool`/`ArrayMesh` greedy meshing for voxel terrain

**Physics**
- **Jolt Physics** (already set in `project.godot`) for units, projectiles, debris
- Height-map collision for terrain walking; voxel grids for structural checks

**Networking**
- **Godot high-level multiplayer** (`ENetMultiplayerPeer`, UDP) — server authoritative
- Headless Godot dedicated servers, one region/shard per process
- `WebSocketPeer` fallback only if a web export is ever needed
- Binary serialization (`PackedByteArray`, optionally Protobuf later)

**Server & Persistence**
- **Headless Godot** region/shard servers (same codebase as client)
- **PostgreSQL** for persistent state — Supabase **boxels** project (shared `profiles`
  table for identity; all CraftPires tables use the `cp_` prefix)
- **Redis** for job queues and caching (optional — add when scale demands it)
- **S3/R2** for blueprint storage

**Why Godot:**
- Open-source, no license fees
- One engine for client AND headless server (shared sim code)
- Rapid GDScript iteration
- Desktop exports (Windows/macOS/Linux) from one project

**Accepted trade-offs:**
- Fewer RTS examples than Unity — we write our own voxel/RTS modules
- Networking less batteries-included than Colyseus — we own the protocol

## Architecture Layers

### Client Layer

**Responsibilities:**
- Render 3D world
- Handle player input
- Display UI
- Stream audio/effects
- Blueprint editor

**Does NOT:**
- Validate game rules
- Process combat
- Handle economy
- Determine winners

**Performance Targets:**
- 60 FPS minimum
- <100ms input latency
- Support 1000+ visible units (LOD)
- Smooth voxel terrain rendering

### Networking Layer

**Protocol**
- **ENet (UDP)** via `ENetMultiplayerPeer` for real-time — unreliable/unordered channels
  for position spam, reliable ordered channels for orders and events
- `WebSocketPeer` fallback reserved for a potential future web export
- Binary serialization (`PackedByteArray`; Protobuf or MessagePack if we outgrow it)

**State Sync**
- Server sends delta updates (only changes)
- Client interpolation for smooth movement
- Server reconciliation for corrections
- Interest management (only nearby entities)

**Message Types**
```gdscript
# Client → Server (RPCs on the client's own authority-scoped node)
# - player_input(move, attack, build orders)
# - chat_message(text)
# - blueprint_upload(packed_voxel_data)

# Server → Client
# - state_update(entity positions, HP, etc.) — delta-compressed
# - event_notification(battle started, building destroyed)
# - chat_broadcast(sender, text)
```

**Bandwidth Optimization**
- 15-20 Hz tick rate for active regions
- 0.5 Hz for inactive regions
- Delta compression
- Spatial culling (only send visible data)

### Game Server Layer

**Region Servers**
- Each region (512×512m) runs on own process
- Stateful: maintains world state
- Authoritative: clients can't cheat
- Scalable: add more regions = add more processes

**Server Tick Loop** (GDScript — headless Godot region server)
```gdscript
# RegionServer runs with --headless; physics tick fixed at 20 Hz
const TICK_RATE := 20.0 # 20 Hz — set physics_ticks_per_second in project settings

func _physics_process(_delta: float) -> void:
    # 1. Process player inputs
    process_input_queue()

    # 2. Update game state
    update_units()
    update_resources()
    update_combat()
    update_buildings()

    # 3. Physics/collisions run via Jolt during the physics step

    # 4. Check victory conditions
    check_victory_conditions()

    # 5. Broadcast state to clients
    broadcast_state()

    # 6. Log events for persistence
    log_events()
```

**Pathfinding**
- Server-side A* on navmesh per region
- Large battles use squad steering (reduce CPU)
- Pre-computed paths cached
- Async processing for complex routes

**Combat Resolution**
- Hit-scan math (not physics simulation)
- Damage = attack × (1 - armor_reduction)
- Morale modifiers applied
- Results deterministic and logged

### Persistence Layer

**PostgreSQL Schema**

CraftPires persistence lives in the Supabase **boxels** project, which is shared across
apps. User identity comes from the shared `profiles` table; every CraftPires table uses
the `cp_` prefix.

```sql
-- Core tables
create table cp_players (
  id bigint generated always as identity primary key,
  profile_id uuid not null references profiles (id),
  prestige bigint default 0,
  cosmetics jsonb default '{}'::jsonb
);
comment on table cp_players is 'Per-app CraftPires player state; identity lives in the shared boxels profiles table.';

create table cp_shards (
  id bigint generated always as identity primary key,
  start_date date not null,
  seed text not null,
  status text default 'active'
);
comment on table cp_shards is 'One row per CraftPires shard (separate game instance / season).';

create table cp_alliances (
  id bigint generated always as identity primary key,
  shard_id bigint references cp_shards (id),
  name text not null,
  banner jsonb
);
comment on table cp_alliances is 'Player alliances within a shard.';

create table cp_regions (
  id bigint generated always as identity primary key,
  shard_id bigint references cp_shards (id),
  bbox box not null,
  snapshot_ptr text,
  last_tick timestamptz
);
comment on table cp_regions is 'World regions within a shard; each maps to a headless Godot server process.';

create table cp_claims (
  id bigint generated always as identity primary key,
  region_id bigint references cp_regions (id),
  owner_id bigint references cp_players (id),
  polygon geometry(Polygon),
  upkeep_cost bigint
);
comment on table cp_claims is 'Territory claims (Keep/Tower radii) within a region.';

create table cp_blueprints (
  id bigint generated always as identity primary key,
  owner_id bigint references cp_players (id),
  name text,
  version int,
  size_dims int[],
  materials jsonb,
  stats jsonb,
  mesh_url text,
  moderation_state text default 'pending'
);
comment on table cp_blueprints is 'Player-authored voxel structure designs (built physically in-game).';

create table cp_structures (
  id bigint generated always as identity primary key,
  blueprint_id bigint references cp_blueprints (id),
  claim_id bigint references cp_claims (id),
  world_pos point,
  hp bigint,
  state text
);
comment on table cp_structures is 'Placed structures in the world (built from hauled materials, never prefab-spawned complete).';

create table cp_inventories (
  id bigint generated always as identity primary key,
  owner_id bigint references cp_players (id),
  shard_id bigint references cp_shards (id),
  items jsonb
);
comment on table cp_inventories is 'Per-shard player/civ resource inventories.';

create table cp_units (
  id bigint generated always as identity primary key,
  owner_id bigint references cp_players (id),
  region_id bigint references cp_regions (id),
  type text,
  pos point,
  hp int,
  orders jsonb
);
comment on table cp_units is 'Persisted unit snapshots (commander, peasants) for offline/24-7 continuity.';

create table cp_wars (
  id bigint generated always as identity primary key,
  attacker_id bigint references cp_alliances (id),
  defender_id bigint references cp_alliances (id),
  start_ts timestamptz,
  end_ts timestamptz,
  regions bigint[]
);
comment on table cp_wars is 'Declared wars between alliances, with affected regions.';
```

**S3/R2 Storage**
- Blueprint meshes (`.glb` or custom format)
- Seasonal archives (full world snapshots)
- Player uploads (screenshots, replays)
- Static assets (textures, models)

**Redis Usage** (optional — introduce only when scale demands it)
- Job queues (pathfinding, AI decisions)
- Caching (frequently accessed data)
- Pub/Sub (cross-region events)
- Session management

### Voxel System

**Voxel Data Structure** (GDScript classes)

```gdscript
class_name VoxelClump
var position: Vector3i
var material_id: int
var voxels: PackedByteArray # 10×10×10 = 1000 bytes
var state: ClumpState # SOLID | PARTIAL | AIR

enum ClumpState { SOLID, PARTIAL, AIR }
```

```gdscript
class_name Chunk
var id: StringName
var bounds: AABB
var clumps: Dictionary # Vector3i -> VoxelClump
var nav_region: NavigationRegion3D
var dirty: bool
```

```gdscript
class_name Region
var id: StringName
var chunks: Dictionary # StringName -> Chunk
var entities: Array[Node3D]
var active_player_count: int
```

**Voxel Meshing**
- Greedy meshing algorithm (combine adjacent voxels)
- LOD system (distant chunks use lower detail)
- Occlusion culling (don't render hidden voxels)
- Bake mesh at build time, stream to clients

**Mining & Modification**
```gdscript
func mine_voxel_clump(region: Region, position: Vector3i, material: int, player: Player) -> void:
    var chunk := get_chunk(region, position)
    var clump: VoxelClump = chunk.clumps.get(position)
    if clump == null:
        return

    # Remove from world
    chunk.clumps.erase(position)
    chunk.dirty = true

    # Add to player inventory
    player.inventory[material] = player.inventory.get(material, 0) + clump.voxels.size()

    # Check structural integrity
    check_supports(region, chunk)

    # Log event
    log_event({
        "type": &"VOXEL_MINED",
        "player": player.id,
        "position": position,
        "material": material,
        "amount": clump.voxels.size(),
    })
```

### Water Physics (Simplified)

**Cellular Automata Approach**

```gdscript
class_name WaterCell
var position: Vector3i
var volume: float # 0-1000 (liters)
var pressure: float
var flow_direction: Vector3


func update_water_flow(region: Region) -> void:
    for cell: WaterCell in region.water_cells:
        # Water flows to lowest neighbor
        var lowest := get_lowest_neighbor(cell)

        if lowest and lowest.height < cell.height:
            var flow_amount: float = minf(
                cell.volume * 0.5,
                (cell.height - lowest.height) * 100.0
            )
            cell.volume -= flow_amount
            lowest.volume += flow_amount

        # Evaporation (slow)
        cell.volume *= 0.999
```

**Performance:**
- Not full Navier-Stokes (too expensive)
- Simplified flow model
- Chunk-based updates
- Only active when players nearby

## Scalability & Performance

### Region Activation

**Active Region Logic**
```gdscript
func should_activate_region(region: Region) -> bool:
    return (
        region.active_player_count > 0
        or region.has_ongoing_war
        or region.has_active_caravan
        or region.has_scheduled_event
    )


func region_tick(region: Region) -> void:
    if should_activate_region(region):
        # Full simulation at 15-20 Hz
        full_simulation_tick(region)
    else:
        # Coarse simulation at 0.5 Hz (a slow SceneTreeTimer-driven pass)
        coarse_simulation_tick(region)
```

**Coarse Simulation** (Inactive Regions)
- Resource regeneration timers
- Farm growth ticks
- Building decay calculations
- No unit movement
- No combat

### Multi-Shard Architecture

**Global Coordinator Service** (lightweight process spawning headless Godot shard servers)
```gdscript
class_name ShardCoordinator

var shards: Dictionary # StringName -> ShardInstance


func create_shard(date: int) -> ShardInstance:
    var shard := ShardInstance.new()
    shard.id = generate_shard_id(date)
    shard.seed = generate_seed()
    shard.start_date = date
    shards[shard.id] = shard
    return shard


func assign_player(player_id: StringName, shard_id: StringName) -> void:
    var shard: ShardInstance = shards.get(shard_id)
    if shard:
        shard.add_player(player_id)
```

**Resource Allocation**
- Each shard gets own database schema/namespace
- Separate region server pools per shard
- Shared asset CDN
- Independent Redis instances

**Scaling Strategy**
- 365 shards × ~3 active regions/shard = ~1,100 region servers
- Auto-scale based on player count
- Kubernetes for orchestration
- Regional clusters (US-East, EU-West, Asia-Pacific)

### Event Sourcing & Recovery

**Event Log**
```gdscript
class_name GameEvent
var id: StringName
var timestamp: int # unix msec — Time.get_unix_time_from_system()
var type: StringName
var region_id: StringName
var data: Dictionary


# All actions append to event log
func log_event(event: GameEvent) -> void:
    event_log.append(event)
    # Publish to subscribers (Redis pub/sub in production)
    pub_sub.publish("region:%s" % event.region_id, event.to_dict())


# Recovery: replay events from snapshot
func recover_region(region_id: StringName) -> Dictionary:
    var snapshot := load_snapshot(region_id)
    var events := load_events_since(snapshot.timestamp)

    var state: Dictionary = snapshot.state
    for event in events:
        state = apply_event(state, event)

    return state
```

**Snapshot Strategy**
- Snapshot every 60 seconds (active regions)
- Snapshot every 15 minutes (inactive regions)
- Keep last 10 snapshots for rollback
- Full event log retained for 30 days

## Development Roadmap

### Milestone 0: Paper Design (Complete ✓)
- Design documents
- Tech stack selection
- Architecture diagrams

### Milestone 1: Greybox RTS (2-3 weeks)
- Top-down camera movement
- Click-to-move units
- Gather wood/stone/food
- Place greybox buildings (full staged voxel construction arrives with Milestone 2)
- Train basic units
- Simple combat
- Single region, local save/load

### Milestone 2: Voxel Editor (2-3 weeks)
- Separate editor mode
- 10×10×10 voxel placement
- Material palette (wood, stone, iron)
- Export blueprint JSON
- Server-side validation
- Instantiate by paying cost

### Milestone 3: Multiplayer Core (3-4 weeks)
- Authoritative headless Godot server (ENet, `ENetMultiplayerPeer`)
- Client-server sync (Godot high-level multiplayer RPCs)
- Interest management
- 2-4 player testing
- Chat system
- Basic auth (Supabase Boxels project)

### Milestone 4: Claims & Warfare (2-3 weeks)
- Territory claims system
- Alliance creation
- War declaration + windows
- Garrison AI (basic)
- Raid license mechanics

### Milestone 5: Regions & Persistence (3-4 weeks)
- Multi-region world
- Region activation/deactivation
- PostgreSQL integration (Supabase boxels project, `cp_` tables)
- Snapshot + event log recovery
- Cross-region travel

### Milestone 6: Resource Warfare (2 weeks)
- Trebuchet ammo system (any resource)
- Building destruction → rubble
- Material recovery mechanics
- Damage types (dirt, stone, explosive)

### Milestone 7: Underground (3 weeks)
- Multi-layer terrain
- Support beam system
- Collapse mechanics
- Underground structures

### Milestone 8: Water Physics (2 weeks)
- Basic flow simulation
- Damming/channeling
- Moats
- Flood mechanics

### Milestone 9: Season & Archive (2 weeks)
- Season timer (accelerated for testing)
- End-of-season snapshot
- Hall of Legends viewer (basic)
- Prestige carryover

### Milestone 10: Polish & Scale (4+ weeks)
- Multi-shard support
- Performance optimization
- Balance tuning
- UI/UX polish
- Security hardening

**Total: ~6-9 months to MVP**

## Security Considerations

**Anti-Cheat**
- Server authoritative (clients can't fake actions)
- Validate all inputs (resource costs, distances, timings)
- Rate limiting (prevent input spam)
- Checksum validation (detect modified clients)

**Exploit Prevention**
- Resource generation audited (no duplication exploits)
- Blueprint validation (prevent banned shapes, impossible stats)
- Trade limits (prevent account selling)
- Automation detection (bot behavior patterns)

**DDoS Protection**
- CloudFlare or similar
- Rate limiting at gateway
- Connection throttling
- Region isolation (attack one shard, others unaffected)

**Data Privacy**
- Encrypted connections (TLS)
- Hashed passwords (bcrypt)
- GDPR compliance (data export/deletion)
- Minimal personal data collection

## Monitoring & Operations

**Metrics**
- Player count per shard
- Active regions per shard
- Tick rate (detect server lag)
- Database query performance
- Event log size
- Blueprint upload rate

**Alerts**
- Server tick below 15 Hz
- Database connection pool exhausted
- Region crash/recovery
- Spike in error events
- Unusual resource generation patterns

**Logging**
- Structured logs (JSON)
- Centralized aggregation (ELK stack or similar)
- Player action audit trail
- Error tracking (Sentry)

---

*Build it iteratively. Test constantly. Scale when needed.*

