# Technical Implementation Plan

## Overview

CraftPires requires a custom voxel engine optimized for massive scale, real-time physics, and multiplayer networking. This document outlines the technical approach using **layer-based rendering** (not chunk loading) and client-side physics.

**Engine: Godot 4.7** (Forward Plus renderer, Jolt Physics — already configured in `project.godot`). All gameplay code is **GDScript**; **GDExtension (C++/Rust)** is the escape hatch for proven hot paths such as voxel meshing, flow-field pathfinding, and compression codecs. The same project exports the headless dedicated server, so client and server share one simulation codebase.

---

## Core Technical Challenges

### 1. Voxel Scale
- **512×512×256m world** per shard (131 million cubic meters)
- **0.1m³ voxel size** = ~131 billion potential voxels per shard
- **50 civilizations** with thousands of structures
- **Real-time destruction** and construction

### 2. Multiplayer Performance
- **50-500+ concurrent players** per shard
- **60 FPS minimum** for smooth RTS gameplay
- **Low latency** (<100ms for actions)
- **Persistent state** across player sessions

### 3. Physics Simulation
- **Water flow** (rivers, floods, mud)
- **Gravity** (falling blocks, collapse)
- **Fire spread** (combustion chains)
- **Collision detection** (units, projectiles, terrain)

### 4. Network Bandwidth
- **Minimize data transfer** (not millions of voxel updates)
- **Layer-based updates** (only changed surface layers)
- **Predictive client** (smooth movement without constant sync)

---

## Revolutionary Approach: Layer Loading (Not Chunk Loading)

### The Problem with Traditional Chunk Loading

**Minecraft-style chunk loading:**
```
32×32×32 chunk = 32,768 voxels loaded
Underground voxels loaded even if never seen
View distance limited by memory (load entire chunks)
Massive waste: 90%+ of voxels underground, never rendered
```

### Layer-Based Loading (97% Memory Reduction!)

**Only load visible layers:**
```
Surface layer: 32×32×1 = 1,024 voxels (TOP layer only)
Underground: Load layers ON-DEMAND when exposed
Caves/mines: Load only when dug into
Savings: 97% less memory usage!
```

**Key Advantages:**
- ✅ **10× view distance** possible (load 10× more horizontal area)
- ✅ **97% memory reduction** for untouched terrain
- ✅ **Dynamic loading** - underground loads as you dig
- ✅ **Massive performance** - only render what's visible
- ✅ **Lower bandwidth** - only send surface layer updates

---

## Layer-Based Terrain System

### Data Structure

```gdscript
class_name LayerChunk
var position: Vector2i             # Only X and Z coordinates (not Y)
var top_layer_y: PackedInt32Array  # Height map (32×32 values)
var surface_voxels: PackedByteArray # Material IDs for top layer (32×32)
var exposed_layers: Dictionary     # y-level (int) -> PackedByteArray of exposed voxels
var is_dirty: bool                 # Needs re-meshing
```

```gdscript
class_name HeightMap
var chunk_position: Vector2i
var heights: PackedInt32Array      # 32×32 array of max Y values
# heights[i] = maximum Y coordinate at column (x, z)
```

```gdscript
class_name ExposedLayer
var y: int                         # Y-level of this layer
var voxels: PackedByteArray        # Only exposed voxels (holes from mining)
var exposure_mask: PackedByteArray # Which voxels are exposed to air
```

### Layer Loading Algorithm

```gdscript
class_name LayerBasedTerrain

# Height map for entire world (always in memory, tiny - 32×32 per chunk)
var height_maps: Dictionary        # Vector2i -> PackedInt32Array

# Surface layers (loaded for visible chunks)
var surface_layers: Dictionary     # Vector2i -> PackedByteArray

# Underground layers (loaded on-demand when exposed)
var underground_layers: Dictionary # Vector3i (x, y, z) -> PackedByteArray

# Exposure tracking (which underground voxels are visible)
var exposed_voxels: Dictionary     # Vector3i -> true (exposed to air)

## Load only visible surface layers.
func load_visible_surface(player_pos: Vector3, view_distance: float) -> void:
    # Get chunks in view (horizontal only)
    var visible_chunks := get_chunks_in_horizontal_range(
        player_pos.x,
        player_pos.z,
        view_distance
    )

    for chunk_pos: Vector2i in visible_chunks:
        # Load height map if not loaded (tiny - just 32×32 heights)
        if not height_maps.has(chunk_pos):
            height_maps[chunk_pos] = await fetch_height_map(chunk_pos)

        # Load surface layer if not loaded (32×32 material IDs)
        if not surface_layers.has(chunk_pos):
            var heights: PackedInt32Array = height_maps[chunk_pos]
            surface_layers[chunk_pos] = await fetch_surface_layer(chunk_pos, heights)

    # Unload distant chunks
    unload_distant_chunks(player_pos, view_distance)

## When a player digs, load the underground layer on-demand.
func dig_voxel(pos: Vector3i) -> void:
    set_voxel(pos, 0) # 0 = air

    # Update height map if the surface changed
    var chunk_pos := world_to_chunk(pos)
    var heights: PackedInt32Array = height_maps[chunk_pos]
    var local := Vector2i(pos.x & 31, pos.z & 31)

    if pos.y == heights[local.x * 32 + local.y]:
        # Surface voxel removed, update height
        heights[local.x * 32 + local.y] = find_new_height(pos)

    # Expose the layer below
    var layer_below := pos.y - 1
    expose_voxel(Vector3i(pos.x, layer_below, pos.z))

    # Load layer below if not loaded
    if not is_layer_loaded(chunk_pos, layer_below):
        load_underground_layer(chunk_pos, layer_below)

## Load an underground layer on-demand.
func load_underground_layer(chunk_pos: Vector2i, y: int) -> void:
    var key := Vector3i(chunk_pos.x, y, chunk_pos.y)
    if underground_layers.has(key):
        return # Already loaded

    # Fetch only this specific layer (from the server, or generate locally)
    underground_layers[key] = await fetch_underground_layer(chunk_pos, y)

    # Mark for re-meshing
    mark_chunk_dirty(chunk_pos)

## Unload layers that aren't exposed anymore (tunnel collapsed).
func unload_filled_layers() -> void:
    for key: Vector3i in underground_layers.keys():
        if not is_layer_exposed(Vector2i(key.x, key.z), key.y):
            underground_layers.erase(key)
```

> In single-player, `fetch_*` reads from the local world generator/save. In
> multiplayer the same functions become RPCs to the headless Godot server — the
> loading algorithm does not change.

### Height Map Optimization

**Height map is TINY:**
```
32×32 chunk = 1,024 height values (2 bytes each)
1,024 × 2 bytes = 2KB per chunk (vs 32KB for full chunk)
Can load 10,000 height maps in 20MB of RAM!
```

**Benefits:**
- Load ALL height maps on game start (tiny memory cost)
- Instant terrain preview from any distance
- No loading delay for height data
- Efficient horizon rendering (distant terrain silhouettes)

---

## View Distance Comparison

### Traditional Chunk Loading
```
View distance: 256m (8 chunks radius)
Chunks loaded: ~200 chunks
Voxels per chunk: 32,768
Total voxels: 200 × 32,768 = 6,553,600 voxels
Memory usage: ~6.5MB (1 byte per voxel)
```

### Layer-Based Loading
```
View distance: 256m (8 chunks radius)
Chunks loaded: ~200 chunks
Surface voxels: 200 × 1,024 = 204,800 voxels
Underground voxels: Only exposed areas (~10%)
Total voxels: ~225,000 voxels
Memory usage: ~225KB (97% reduction!)
```

### Extended View Distance (Layer Loading)
```
View distance: 1024m (32 chunks radius!)
Chunks loaded: ~3,200 chunks
Surface voxels: 3,200 × 1,024 = 3,276,800 voxels
Underground voxels: Only exposed (~10%)
Total voxels: ~3.6 million voxels
Memory usage: ~3.6MB (same as 256m traditional!)

RESULT: 4× view distance with same memory usage!
```

---

## Rendering Optimization

### Greedy Meshing (Per Layer)

Instead of meshing entire chunks, mesh ONLY loaded layers. In Godot this maps
directly onto `SurfaceTool` building an `ArrayMesh` per chunk (start naive —
one quad per exposed face with hidden-face culling — then upgrade runs of
identical material to greedy-merged quads once profiles justify it):

```gdscript
class_name LayerMesher

func generate_surface_mesh(chunk: LayerChunk) -> ArrayMesh:
    var st := SurfaceTool.new()
    st.begin(Mesh.PRIMITIVE_TRIANGLES)

    # Greedy-mesh ONLY the surface layer (not a 32×32×32 chunk)
    for x in 32:
        for z in 32:
            var y: int = chunk.top_layer_y[x * 32 + z]
            var material: int = chunk.surface_voxels[x * 32 + z]
            if material == 0:
                continue # Skip air

            # Emit quads only for exposed faces
            add_quad(st, Vector3i(x, y, z), Direction.UP, material) # Top always sky-exposed
            if is_exposed(Vector3i(x, y, z + 1)):
                add_quad(st, Vector3i(x, y, z), Direction.NORTH, material)
            if is_exposed(Vector3i(x, y, z - 1)):
                add_quad(st, Vector3i(x, y, z), Direction.SOUTH, material)
            if is_exposed(Vector3i(x + 1, y, z)):
                add_quad(st, Vector3i(x, y, z), Direction.EAST, material)
            if is_exposed(Vector3i(x - 1, y, z)):
                add_quad(st, Vector3i(x, y, z), Direction.WEST, material)
            if is_exposed(Vector3i(x, y - 1, z)):
                add_quad(st, Vector3i(x, y, z), Direction.DOWN, material)

    st.generate_normals()
    var mesh := st.commit()
    mesh.surface_set_material(0, terrain_material) # vertex-color or texture-array material
    return mesh

func generate_underground_mesh(layer: ExposedLayer) -> ArrayMesh:
    # Only mesh exposed underground voxels — same process, gated on exposure_mask
    ...
```

> **Performance note:** `SurfaceTool` is convenient but not the fastest path.
> If profiles show meshing as a bottleneck (large digs, many dirty chunks per
> frame), build the vertex/index arrays directly (`ArrayMesh` from
> `PackedVector3Array`/`PackedInt32Array`) or move the mesher to a
> GDExtension. See `godot-build-plan.md` for when to make that jump.

### LOD (Level of Detail) for Distant Terrain

```gdscript
enum LODLevel { FULL, MEDIUM, LOW, VERY_LOW }

func generate_lod_mesh(chunk: LayerChunk, lod_level: int) -> ArrayMesh:
    match lod_level:
        LODLevel.FULL:     # 0-64m: mesh every voxel
            return generate_surface_mesh(chunk)
        LODLevel.MEDIUM:   # 64-256m: 2×2 voxel groups
            return generate_simplified_mesh(chunk, 2)
        LODLevel.LOW:      # 256-1024m: 4×4 voxel groups
            return generate_simplified_mesh(chunk, 4)
        _:                 # 1024m+: entire chunk = 1 quad
            return generate_single_quad(chunk)
```

---

## Network Optimization

### Layer-Based Updates

**Only send changed surface layers** (dictionaries over Godot RPC, or packed
bytes on an unreliable ENet channel):

```gdscript
class_name VoxelChange
var local: Vector2i  # 0-31
var material: int    # New material ID

class_name LayerUpdate
var chunk_id: Vector2i
var layer_y: int                 # Which layer changed
var changes: Array[VoxelChange]  # Only changed voxels
var timestamp: int

# Example: player mines 5 surface voxels — one small RPC payload
var update := {
    "chunk": Vector2i(10, 15),
    "layer_y": 42, # Surface at Y=42
    "changes": [
        { "local": Vector2i(10, 15), "material": 0 }, # Air
        { "local": Vector2i(11, 15), "material": 0 },
        { "local": Vector2i(12, 15), "material": 0 },
        { "local": Vector2i(10, 16), "material": 0 },
        { "local": Vector2i(11, 16), "material": 0 },
    ],
    "timestamp": Time.get_ticks_msec(),
}
# Network payload: ~50 bytes (vs 32KB full chunk!)
```

### Delta Compression

```gdscript
class_name LayerDeltaEncoder
var last_sent_state: Dictionary # Vector2i -> PackedByteArray

func encode_delta(chunk_id: Vector2i, current_layer: PackedByteArray) -> Array:
    if not last_sent_state.has(chunk_id):
        # First time: send the full layer (RLE compressed)
        return compress_full_layer(current_layer)

    # Send only differences
    var last: PackedByteArray = last_sent_state[chunk_id]
    var changes: Array = []
    for i in current_layer.size():
        if current_layer[i] != last[i]:
            changes.append({
                "local": Vector2i(i / 32, i % 32),
                "material": current_layer[i],
            })

    last_sent_state[chunk_id] = current_layer
    return changes
```

### Run-Length Encoding (RLE)

For initial layer sends (empty terrain):

```gdscript
func compress_layer(layer: PackedByteArray) -> PackedByteArray:
    var compressed := PackedByteArray()
    var current := layer[0]
    var count := 1

    for i in range(1, layer.size()):
        if layer[i] == current and count < 255:
            count += 1
        else:
            compressed.append(current)
            compressed.append(count)
            current = layer[i]
            count = 1

    compressed.append(current)
    compressed.append(count)
    return compressed

# Example: 1,024 grass voxels compress to ~10 bytes!
# [GRASS_ID, 255, GRASS_ID, 255, GRASS_ID, 255, GRASS_ID, 255, GRASS_ID, 4]
```

---

## Performance Benchmarks

### Memory Usage

**Traditional Chunk Loading:**
- 256m view distance: 6.5MB voxel data
- 512m view distance: 26MB voxel data
- 1024m view distance: 104MB voxel data (impractical!)

**Layer-Based Loading:**
- 256m view distance: 225KB voxel data (97% reduction)
- 512m view distance: 900KB voxel data (97% reduction)
- 1024m view distance: 3.6MB voxel data (97% reduction)

**Realistic Underground Exposure (~10% of terrain):**
- Surface: 1,024 voxels per chunk
- Underground exposed: ~3,000 voxels per chunk (caves, mines)
- Total: ~4,000 voxels per chunk (vs 32,768 traditional)
- Memory savings: 88%

### Frame Rate Targets

**60 FPS minimum:**
- 16.6ms frame budget
- Layer meshing: <5ms per chunk
- Rendering: <10ms for all visible geometry
- Physics: <1ms for local interactions

**Optimizations:**
- Frustum culling (Godot does this automatically per `VisualInstance3D`)
- Occlusion culling (don't render hidden layers)
- Instanced rendering (`MultiMeshInstance3D` for repeated structures/units)
- Batching (combine meshes; keep chunk count per material low)

### Network Performance

**Traditional Chunk Sync:**
- 32KB per chunk (uncompressed)
- 200 chunks = 6.4MB initial load
- Impractical for 500+ players

**Layer-Based Sync:**
- 2KB per surface layer (height map + RLE)
- 200 chunks = 400KB initial load
- Realistic for 500+ players

---

## Physics System

### Client-Side Prediction

Units are `CharacterBody3D` nodes driven by Jolt Physics (set in
`project.godot`); ground height comes from the height map, not raycasts:

```gdscript
extends CharacterBody3D
## Client predicts movement; the server validates and reconciles.

var last_sent_msec := 0

func _physics_process(delta: float) -> void:
    # Client predicts movement
    apply_gravity(delta)
    apply_input()
    check_ground_collision() # Only check top layer!

    move_and_slide()

    # Send movement to server (100ms intervals)
    if Time.get_ticks_msec() - last_sent_msec > 100:
        send_movement_to_server()
        last_sent_msec = Time.get_ticks_msec()

func check_ground_collision() -> void:
    # Only check surface layer (not underground)
    var x := floori(position.x)
    var z := floori(position.z)
    var ground_y: float = terrain.get_height_at(x, z) # From height map!

    if position.y <= ground_y + 1.0:
        velocity.y = 0
        position.y = ground_y + 1.0
```

### Water Flow Simulation

```gdscript
func simulate_water_flow(chunk: LayerChunk) -> void:
    # Only simulate visible water layers
    for x in 32:
        for z in 32:
            var surface_y: int = chunk.top_layer_y[x * 32 + z]

            # Check if surface voxel is water
            if chunk.surface_voxels[x * 32 + z] != MaterialIds.WATER:
                continue

            # Flow downward (expose layer below if needed)
            flow_down(Vector3i(x, surface_y, z))
            # Flow sideways
            flow_sideways(Vector3i(x, surface_y, z))
```

---

## Technical Stack (Chosen: Godot 4.7)

### Game Engine
**Godot 4.7** (set in `project.godot`)
- **GDScript** primary — rapid iteration, one language across client and server
- **Forward Plus** renderer; **Jolt Physics** for units, projectiles, debris
- Layer-based rendering maps cleanly onto `SurfaceTool`/`ArrayMesh`
- **GDExtension (C++/Rust)** reserved for proven hot paths: greedy meshing,
  flow-field pathfinding, RLE/delta codecs
- Open source, no license fees, desktop exports from one project

### Server Backend
**Headless Godot dedicated server** (same project, `--headless`)
- Shares the simulation code with the client — no duplicate implementation
- One process per shard/region; a lightweight coordinator spawns/monitors them
- **Cons**: we own the protocol (less batteries-included than room frameworks)

### Database
**PostgreSQL via Supabase (boxels project) + optional Redis**
- **PostgreSQL**: persistent storage (layers, players, civs) — CraftPires tables
  are `cp_`-prefixed; user identity comes from the shared `profiles` table
- **Redis**: optional in-memory cache/queues — add when scale demands it
- **Layer storage**: store only surface + exposed layers (schema below)

### Networking
**Godot high-level multiplayer over ENet (UDP)**
- `ENetMultiplayerPeer` with reliable/unreliable channels — ideal for layer
  updates (small payloads) and position spam
- `WebSocketPeer` option kept for a potential future web export
- **Alternative**: custom UDP via `PacketPeerUDP` (more complex, more control)

---

## Database Schema for Layer-Based Storage

Tables live in the Supabase **boxels** project with the `cp_` prefix:

```sql
-- store only surface layers (tiny!)
create table cp_surface_layers (
  id bigint generated always as identity primary key,
  shard_id bigint not null references cp_shards (id),
  x int not null,
  z int not null,
  height_map bytea not null,      -- 32×32 heights (2KB)
  surface_voxels bytea not null,  -- 32×32 materials (1KB compressed)
  last_modified timestamptz default now(),
  unique (shard_id, x, z)
);
comment on table cp_surface_layers is 'Surface voxel layer + heightmap per 32×32 chunk; the only terrain data sent on join.';

create index idx_cp_surface_layers_shard_position on cp_surface_layers (shard_id, x, z);

-- store only exposed underground layers
create table cp_underground_layers (
  id bigint generated always as identity primary key,
  surface_layer_id bigint not null references cp_surface_layers (id),
  y int not null,
  voxel_data bytea not null,  -- RLE compressed
  exposure_mask bytea,        -- which voxels are exposed
  last_modified timestamptz default now(),
  unique (surface_layer_id, y)
);
comment on table cp_underground_layers is 'Underground voxel layers, persisted only while exposed (mines, caves, tunnels).';

create index idx_cp_underground_layers_chunk_y on cp_underground_layers (surface_layer_id, y);
```

**Storage savings:**
- Traditional: 32KB per chunk (always)
- Layer-based: 3KB per chunk (surface only)
- Underground: +1-5KB per chunk (only if exposed)
- **Total savings: ~85% storage reduction**

---

## Development Roadmap

### Phase 1: Core Layer System (2-3 months)
- [ ] Height map data structure (`PackedInt32Array` per 32×32 chunk)
- [ ] Surface layer loading/unloading
- [ ] Layer-based meshing via `SurfaceTool`/`ArrayMesh` (naive first, greedy later)
- [ ] Basic collision with height map lookup (+ Jolt for units)
- [ ] Layer synchronization boundary (single-player first; RPC-ready API shape)

### Phase 2: Underground On-Demand (1-2 months)
- [ ] Underground layer loading when exposed
- [ ] Cave system rendering
- [ ] Collapse mechanics (unload filled layers)
- [ ] Water exposure (load layers when flooded)

### Phase 3: Optimization (1-2 months)
- [ ] LOD system for distant layers
- [ ] Frustum + occlusion culling (underground)
- [ ] Delta compression for layer updates
- [ ] RLE compression for initial loads
- [ ] Move meshing to GDExtension if profiles demand it

### Phase 4: Physics Integration (1 month)
- [ ] Water flow on layers
- [ ] Gravity (falling voxels update height map)
- [ ] Fire spread on surface layer
- [ ] Collision detection with layers

---

## Performance Targets

### Client Performance
- **60 FPS minimum** (16.6ms frame time)
- **View distance**: 1024m (32 chunk radius) with layer loading
- **Max visible voxels**: ~3-5 million (after greedy meshing: ~500k triangles)
- **Memory usage**: <2GB RAM
- **Load time**: <5 seconds to join world (height maps pre-loaded)

### Server Performance
- **50 civilizations** per shard (500+ players)
- **Tick rate**: 20 TPS (50ms per tick) — `physics_ticks_per_second = 20`
- **Layer updates**: <1ms per layer change
- **AI peasant updates**: <1ms per 100 peasants
- **Database writes**: Batch every 30 seconds

### Network Performance
- **Bandwidth per player**: <200 KB/s (layer loading)
- **Ongoing bandwidth**: <20 KB/s (layer updates only)
- **Latency**: <100ms for actions
- **Update frequency**: 20 updates/second (position, state)

---

## Critical Advantages of Layer Loading

### 1. Massive View Distance
- Can render 1km+ view distance (4× traditional)
- Perfect for RTS overview (see entire battlefield)
- Strategic planning (scout entire region)

### 2. Memory Efficiency
- 97% less memory for untouched terrain
- Can support more players per shard
- Lower client hardware requirements

### 3. Network Efficiency
- Only send surface layer initially (tiny)
- Underground loaded on-demand (rare)
- Perfect for 500+ player servers

### 4. Dynamic World
- Underground only loads when dug
- Collapsed tunnels automatically unload
- Flooded areas load as water spreads
- Efficient for persistent world modifications

### 5. Scalability
- Add more horizontal area easily (just surface layers)
- Underground complexity doesn't affect performance
- Can expand world without memory concerns

---

*Layer-based loading: The key to massive view distances, 500+ players, and persistent voxel worlds. Load only what's visible, render only what's needed.*
