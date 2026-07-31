# Multiplayer Design — Authoritative Reference

> **This game is fully multiplayer.** Every mechanic, control, and system we
> add must be designed as if other players are already in the world. This doc
> consolidates the multiplayer decisions scattered across `core-concepts.md`,
> `technical-architecture.md`, and `technical-implementation-plan.md`, and
> adds the engineering ground rules the Godot prototype follows so nothing we
> build today has to be thrown away when networking lands.

---

## Player structure (per shard)

| Layer | Count | Notes |
| --- | --- | --- |
| Shard (one map) | 512×512×256m | Separate game instance; worlds expand by adding shards |
| Civilizations per shard | **up to 50** | The hard cap per map |
| Humans per civilization | **1–10** | 1 Commander + up to 9 human-controlled peasants |
| Max humans per shard | **~500** | 50 civs × 10 humans |
| AI peasants | unlimited (housing-capped) | Controlled by the Commander player |

- **Cross-shard travel**: players can move between shards to help allies or attack.
- **Expanding worlds**: new shards are added as demand grows — the "map count" scales, not the map size.
- **24/7 persistence**: shards run year-long seasons; AI automation keeps civs alive offline.
- The current Godot prototype targets a 128×128×64 single-player shard — a scaled-down slice of one civ's corner of a real shard (see [`godot-build-plan.md`](./godot-build-plan.md)).

## The Commander comeback doctrine

Design intent (the AoE2 "never resign" nod): **as long as your Commander
lives, your civilization can rebuild from nothing.**

- The Commander alone can gather meaningfully without infrastructure: beam-gather
  fills his personal 100-unit cargo hold from any block, anywhere.
- The Commander alone can place foundations — so a lone surviving Commander can
  found a new Keep/houses and buy new peasants to keep fighting.
- Peasant supply lines (peasants collecting from the Commander's cargo) are a
  strategy layer on top, not a requirement — losing all peasants never
  soft-locks a civ.
- Killing the enemy Commander is therefore the decisive strategic blow
  (respawn exists but is expensive and slow — see `commander-system.md`).

Anything we add later (upgrades, warfare, economy) must preserve this loop:
**Commander alive → resources → foundations → peasants → civilization.**

## Engineering ground rules (Godot prototype)

These keep the single-player prototype network-ready. Check every new system
against this list.

1. **Commands are the boundary.** All unit behavior is triggered through
   explicit order methods (`order_move`, `order_gather`, `order_mine`,
   `order_collect_from`, …). Input handlers translate clicks into orders; the
   simulation only consumes orders. Orders are what will serialize over the
   wire — never mutate sim state directly from input code.
2. **IDs, not references, across boundaries.** Units, buildings, and resource
   nodes all have numeric ids; tasks reference targets by id and look them up
   (`buildings.by_id`, `resources.by_id`). A dead reference is a
   normal, handled case — exactly like a stale network entity.
3. **Deterministic where it matters.** World generation is seeded
   (`RandomNumberGenerator` with a fixed `seed`); gameplay logic avoids
   wall-clock time. Cosmetic-only effects (particles, wobble) may use the
   global `randf()`/`randi()` freely — they never feed back into sim state.
4. **Ownership is coming.** Every unit/building will gain a `civId` (and
   human-controlled peasants a `playerId`). Prototype default civ is
   **Larpites** (`larpites`) — see [`civilizations.md`](./civilizations.md).
   Until then, assume "player 1 owns everything" is temporary scaffolding.
5. **Resources become per-civ.** The current global HUD resource stockpile
   will become per-civilization state; keep resource mutations going through
   the single `add_resource` / `spend` funnel on the events autoload so the
   swap is one change, not fifty.
6. **Selection is client-local.** Selection, hover hints, camera, and UI are
   per-player view state and must never affect the simulation.
7. **Server-authoritative target.** Long-term the sim runs on the server (or
   deterministic lockstep); the client is renderer + input. Don't build
   mechanics that depend on client-side raycasts for truth — raycasts pick
   *targets*, orders carry world coordinates/ids.

## Decision checklist for every new mechanic

When a docs pass adds a mechanic, answer these before implementing:

- **Who owns it?** (civ / player / global / client-local view)
- **What order triggers it?** (must be an `order_x`-style command)
- **Is it deterministic?** (same inputs → same result on every machine)
- **What syncs?** (which state must other players see, at what rate)
- **Does it break the comeback doctrine?** (can a lone Commander still rebuild)

## Open questions (to resolve in future passes)

- Max civs per *prototype* shard for early network tests (2? 4?).
- Lockstep-deterministic sim vs server-authoritative state sync (leaning
  server-authoritative per `technical-implementation-plan.md`).
- Human-peasant control mode (direct WASD control vs order-based) — affects
  input latency requirements.
- Newbie immunity rules and spawn placement on crowded shards.
