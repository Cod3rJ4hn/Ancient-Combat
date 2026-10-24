# Ancient Combat

2D side-on ancient-era PvE combat game. Realistic, brutal, with satisfying combat, gore effects, and many weapon and enemy types over time.

## Stack

- Godot 4.3 (standard build), GL Compatibility renderer
- GDScript only
- Viewport 1280x720, nearest-neighbour texture filtering (pixel art)

## Layout

- `scenes/` – Godot scenes
- `scripts/` – GDScript
- `assets/sprites/`, `assets/audio/` – art and sound
- `scripts/game_feel.gd` – autoload `GameFeel` with `hit_stop()` and `shake()`

## Rules

- Scope: one weapon and one enemy first. Get the hit feeling great (hit-stop, screen shake, blood particles, enemy stagger) before adding any more weapons or enemies. New weapons and enemies are variations on that loop.
- Stay 2D. No 3D.
- Ultra realistic. No jumping: movement is grounded (walk, run, dodge, block).
- Placeholder art is fine. Use free packs (itch.io) and don't let art block combat work.
- Use `GameFeel` for hit-stop and shake rather than duplicating that logic.
- Keep scripts small and readable. The owner is a beginner with Godot.

## Working with Jahn

- Jahn runs the game and reports how it feels ("floaty", "flat blood"); Claude tunes it. Claude can't play the game or draw sprites.
- Australian English. Short, direct answers. Pick one recommendation rather than listing options.
- One step at a time. Don't dump a whole plan unless asked.
- Push back when something is wrong, naming the specific problem.

## Git

- Branch: `main`
- Remote: github.com/Cod3rJ4hn/Ancient-Combat

## Next

1. Player: move, one attack (no jump)
2. One enemy that takes hits and staggers
3. Hit feel: hit-stop, shake, blood particles
