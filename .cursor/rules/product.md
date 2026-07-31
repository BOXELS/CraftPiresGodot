---
description: Product context — what CraftPires is, who it's for, and where it's going.
alwaysApply: true
---

# Product Rules

## What this is

**CraftPires** is a hybrid RTS + Minecraft-inspired "forever game": players mine, build, and wage war in a persistent voxel world. Think Age of Empires II economy + The Settlers II logistics + Empire Earth ages + Minecraft creativity — year-long seasons where civilizations leave permanent scars on the map.

Repo: [BOXELS/CraftPiresGodot](https://github.com/BOXELS/CraftPiresGodot). Engine rebuild is Godot 4.7 from scratch (web/Unity prototypes retired).

## Who uses this

Primary: RTS fans who want deeper resource/logistics gameplay and Minecraft players who want strategic competition. Secondary: co-op teams (1 Commander + up to 9 human peasants) and forever-game / seasonal-world players.

## Design pillars (non-negotiable)

- Resources ARE the game — physical voxels, hauling, reclaim from destruction.
- No prefabs — all construction is voxel-based with Settlers-style material delivery.
- Unlimited AI peasants (housing-limited), like AoE II — not a hard 1–9 peasant cap.
- 1 Commander per civ (beam mining, strategic control, respawns with cost).
- Terrain remembers — digs, floods, collapses persist for the season.
- MVP is single-player / network-ready; multiplayer comes after the core loop works.

## Key user flows (MVP)

1. Spawn → place Keep → train peasants → gather wood/stone/food → build houses → expand economy.
2. Commander beam-mines → auto-deposit → assign peasants gather/haul/build → watch staged construction.
3. Craft tools → unlock recipes → staff Toolsmith → improve harvest rates.

Post-MVP flows: warfare/siege, ages 2–3, multiplayer co-op, cross-shard travel, season prestige.

## Roadmap

Follow `docs/godot-build-plan.md` phases in order:
0 scaffolding → 1 terrain+camera → 2 commander+resources → 3 peasant AI → 4 construction → 5 crafting → 6 fog/claim/save → 7 multiplayer.

Do not pull Phase 7 (or out-of-MVP systems: water sim, siege, crypto) into earlier phases without an explicit ask.

## Tone

Playful war-and-wonder toybox — epic strategy with room for hilarious physics failures. In-game copy should be clear and lightly cheeky, never corporate. Errors should tell the player what to do next ("Need more wood at the site board") not dead-end.

## Positioning

Not pure Minecraft (strategy + logistics matter). Not pure AoE (terrain is destructible and permanent). Not abstract resource counters — materials have weight and presence. Never suggest instant-build prefabs, immunity shields as the offline model, or pay-to-win combat power.

## Legal / monetization

Cosmetic / season rewards may come later. Crypto/NFT content in docs is **out of MVP** and needs explicit legal review before any implementation. Don't scaffold token or NFT systems unless asked.
