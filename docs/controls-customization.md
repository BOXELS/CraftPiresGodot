# Controls & Shortcut Customization

> Defaults live in `scripts/core/controls.gd` (on top of Godot's `InputMap`).
> Players will eventually remap **every** binding; registered accounts store
> overrides in the player database (Boxels shared profiles — CraftPires-prefixed
> tables). Until Settings + auth land, the defaults file is authoritative.

**Status:** design + current default behavior. Remap UI and DB persistence are
**not shipped**.

---

## Default priority

When inventing a new binding, prefer familiarity in this order:

1. **Age of Empires II** (RTS menu drill-down, peasant/military groups, idle `.`)
2. **Minecraft** (F-mode WASD, jump, inventory craft feel)
3. Other well-known RTS / sandbox schemes only if 1–2 conflict

Document the choice in `controls.gd` when it is non-obvious.

---

## Nested build menus (load-bearing)

Build bar is a depth stack: **category → folder → size / item** (future: deeper
folders). While any level is open:

| Input | Behavior |
| --- | --- |
| Number key | Selects the **current depth** row with that hotkey |
| Esc | Pops one level (folder → category → closed) |
| Category digit again | Does **not** steal a child slot to pop (e.g. `1→2→1` = Small House, not “back”) |

Closing a category from the keyboard is **Esc** (or click the category button).
This matches AoE2-style drill-down and must stay true when sub×3 menus land.

---

## Remapping (future)

- Every action in `CONTROLS` / build menu nodes / F-mode gets a stable
  **`bindingId`** (string). Defaults map `bindingId → key chord`.
- Settings UI edits the map; conflicts warned (two actions, one key).
- Context still matters: peasant-selected `1–4` vs build bar vs house duty —
  remaps apply per **context**, not one global digit.

### Persistence (registered players)

| Layer | Store |
| --- | --- |
| Guest / local | `user://settings.cfg` (`ConfigFile`) until login |
| Registered | Boxels Supabase profile — CraftPires-prefixed table, e.g. `cp_keybinds` keyed by `user_id` + `binding_id` |
| Sync | Load on login; write on Settings save |

Do not invent schema in this pass — when auth lands, add a migration under the
Boxels project and a thin loader that merges overrides onto `controls.gd`
defaults.

---

## Related

- `scripts/core/controls.gd` — defaults + HUD help
- [`development.md`](./development.md) — agent rule: update `controls.gd` with bindings
- Design invariants — nested menu key lock + Esc back
