---
description: Security guardrails for CraftPires — secrets, authority, saves, and future multiplayer.
alwaysApply: true
---

# Security Rules

## Secrets and API keys

- **Never** hardcode Supabase service role keys, DB passwords, or third-party secrets in GDScript, scenes, or committed config.
- Client-safe: Supabase anon/publishable keys only when auth is intentionally client-side.
- Server-only: service role, admin tokens, webhook secrets — headless server / CI / edge functions only.
- Never log secrets. Never put them in error dialogs or RPC responses.
- Don't commit `.env` files with live credentials.

## Game authority (critical for Phase 7; design for it now)

- The **server is authoritative** for world mutations (voxels, inventories, combat outcomes) once multiplayer exists.
- Client-side checks (hiding buttons, local "can afford?") are UX only — never the only enforcement.
- Orders (`order_*`) are the trust boundary: validate on the authority before applying.
- Don't trust client-reported resources, fog reveal, or claim ownership without server verification later.

## Saves and local files

- Write saves only under `user://`. Validate/version save payloads on load — treat files as untrusted input.
- Prefer allowlisted enums for material IDs, tool types, and order kinds when deserializing.
- Don't execute scripts or expressions from save data.

## Supabase / database (Phase 7+)

- Use the **Boxels** Supabase project only. App tables: **`cp_` prefix**. Shared `profiles` for users.
- Enable **RLS** on every new table before use; at least one policy required.
- Parameterized queries / official client only — never string-concatenated SQL.
- Verify schema via Supabase MCP before writing queries or migrations — don't guess columns.
- Service role bypasses RLS: justify every use; never ship it in the game client.

## Input validation

- Validate at every trust boundary: RPC args, CLI `--scenario=` names (allowlist), remapped keybinds, chat/text if added.
- Prefer allowlists for scenario names, building types, and tool IDs.
- File/mod imports (if ever added): validate type/size; don't load arbitrary executables.

## Multiplayer anti-abuse (when networking lands)

- Interest management: don't broadcast full-shard voxel state to every peer.
- Rate-limit order spam and chat on the server.
- Never expose other players' private inventories or fog-unrevealed state.
- Destructive admin actions need explicit confirmation and should be logged.

## XSS / HTML (usually N/A)

- Native Godot UI does not use an HTML renderer. If a web marketing site or Web export with HTML overlays is added later, sanitize any user/HTML content before render — don't assume game rules cover it.

## Sensitive operations

- Irreversible actions (delete save, abandon civ, wipe shard) require explicit confirmation.
- Crypto/NFT or real-money features are out of MVP and require an explicit security + legal pass before any code.
