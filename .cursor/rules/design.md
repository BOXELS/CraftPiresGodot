---
description: In-game UI/UX and visual standards for CraftPires (HUD, menus, feedback).
alwaysApply: true
---

# Design Rules

## Context

This is a **3D RTS + voxel game**, not a web app. Prefer Godot `Control` nodes for HUD/menus and world-space feedback for gameplay. Do not introduce React/HTML/CSS component libraries.

## Visual direction

- Organic fine-grain voxels (not chunky Minecraft cubes). Vertex colors / simple materials first; art polish later.
- Civilization identity emerges from materials and builds — UI should stay readable and secondary to the world.
- Avoid generic "AI slop" looks: purple-on-white gradients, glow-everything dark mode, emoji-as-UI.
- Procedural / primitive meshes are fine for MVP characters (blend-shell style capsules/primitives).

## HUD and menus

- Built with Godot `Control` / theme resources under `scenes/ui/` and `scripts/ui/`.
- One clear job per panel (resources, selection, site board, craft sheet). Don't dashboard-clutter the first playable view.
- Craft sheet is a modal (**C**) — Esc closes; don't trap focus without an exit.
- Nested menu key lock + Esc-back invariants from `docs/controls-customization.md` are load-bearing — preserve them.
- Prefer text + simple icons over card grids and pill clusters.

## Interaction states

Every interactive control needs idle / hover / focus / disabled. Async actions (save, craft, staff) need a busy state and must prevent double-submit.

- **Loading**: short status line or spinner in-panel — never a blank HUD.
- **Empty**: helpful prompt ("No tools yet — open Craft (C)") — never an empty silent box.
- **Error**: inline near the action ("Need 10 wood") — not only a toast if the player must fix inventory.
- **World feedback**: cursors/decals for mine/build targets; scaffold/site boards for construction progress.

## Camera and controls

- RTS camera: pan (WASD/arrows), rotate (Q/E), zoom (wheel, pitch tied), MMB drag-pan — see build plan Phase 1.
- Defaults follow AoE2 → Minecraft-inspired mappings in `docs/controls-customization.md`; remaps persist in `user://`.
- Keep camera-basis strafe/drag-pan signs correct — known hazard from the old prototype.

## Motion and juice

- Use motion for hierarchy and feedback (selection pulses, haul paths, build stage pops) — not constant screen noise.
- Respect a future reduced-motion setting if added; until then, keep non-essential juice optional and subtle.

## Accessibility (best-effort MVP)

- Keyboard-navigable menus; logical focus order.
- Don't rely on color alone for resource/faction identity — pair with labels/icons.
- Readable contrast on HUD over bright terrain (shadow/backdrop behind text if needed).

## Audio

- Godot audio buses; procedural/`AudioStreamGenerator` OK for MVP. No WebAudio ports.
