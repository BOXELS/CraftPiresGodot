---
description: Tech stack, coding conventions, and engineering standards for the Godot build.
alwaysApply: true
---

# Tech Rules

## Language and framework

- **Godot 4.7**, Forward Plus renderer, **Jolt Physics** — configured in `project.godot`.
- Primary language: **typed GDScript**. GDExtension/C++ only for proven hot paths (first candidate: voxel meshing) — ask before adding.
- Do not introduce Unity, Three.js, React, Node game clients, or alternate engines.
- Scenes are composition roots; scripts hold logic. Prefer composition over deep inheritance.

## Code organization

- Files: `snake_case.gd` / `snake_case.tscn`. Classes: `PascalCase` via `class_name` when shared.
- Group by domain under `scripts/` (`core/`, `world/`, `units/`, `buildings/`, `game/`, `ui/`) — see structure rules.
- Functions do one thing. Prefer splitting when a function grows past ~40 lines of mixed concerns.
- Autoloads only for true globals: `Events`, `Sim`, `Controls` (per build plan). Don't invent new autoloads without asking.

## Gameplay / simulation conventions

- Follow `docs/multiplayer-design.md` engineering ground rules even in single-player MVP:
  - Commands are the boundary: `order_move`, `order_gather`, `order_mine`, etc.
  - Deterministic sim tick + seeded `RandomNumberGenerator` via `Sim`.
  - Resource mutations go through the `Events` funnel (`add_resource` / `spend`) — no silent inventory writes.
- Voxel world: layer-based loading (heightmap + surface layer; underground on demand). Chunks are 32×32 horizontally. Prefer `PackedByteArray` for dense voxel/material data.
- Meshing: `SurfaceTool` / `ArrayMesh`; naive faces OK first, greedy meshing when profiling warrants.
- Navigation: flow fields on the column grid (`navigation.gd`); `NavigationAgent3D` only for local avoidance if needed.
- Settings/saves: `user://` via `ConfigFile` / `FileAccess` — never browser `localStorage` patterns.
- Scenarios: `--scenario=<name>` via `OS.get_cmdline_user_args()`; scenes under `tests/scenarios/`.

## Data and state

- Definitions (materials, tools, buildings, civs) live as `.tres` under `data/` — not hardcoded magic numbers scattered in UI.
- Validate at trust boundaries once multiplayer lands (RPC payloads, save files). Prefer allowlists for enums/material IDs.
- Client prediction later; **server is authority** for world mutations in Phase 7.

## Persistence and backend (Phase 7+)

- Database: **Supabase Postgres on the Boxels project**. Tables for this app use the **`cp_` prefix**. Shared `profiles` table — do not fork user identity into a CraftPires-only users table.
- Never use the DijiArt Supabase project here.
- Optional Redis cache later — don't add it in MVP.
- Networking: Godot dedicated server (headless export) + **ENet** first; WebSocket only if a web client is explicitly planned.

## Secrets

- No hardcoded API keys, service role keys, or DB URLs in client scenes/scripts.
- Supabase anon key may live in client config when auth exists; service role stays server-side / CI secrets only.
- Never commit `.env` files with secrets.

## Git

- Descriptive present-tense commit messages (why over what). One logical change per commit.
- Never commit `.godot/`, secrets, or `.DS_Store`.
- Don't commit unless the user asks.

## Testing

- Prefer scenario scenes (`tests/scenarios/`) that pass/fail with a clear exit code under headless Godot.
- After gameplay or pathing changes, run relevant scenarios when Godot CLI is available.
- CI target: `godot --headless --path . --quit` must parse/import cleanly.

## Deployment

- Desktop exports first (macOS/Windows/Linux). Headless Linux server export for multiplayer later.
- Don't assume Netlify/Vercel for the game client — those skills apply only if we add a separate marketing site.
