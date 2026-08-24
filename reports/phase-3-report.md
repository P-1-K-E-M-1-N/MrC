# MrC — Phase 3 Report: First Live Enemies

Session date: 2026-08-23 · Status: **ready for playtest — it can fight back now**

## What was built

- **Hero damage intake:** the hero has a hurtbox, takes hits, flashes on
  damage, and gets **0.6 s of invulnerability** after each hit so a crowd
  can't melt you instantly. HP shows on the HUD as before.
- **Respawn:** dying (or falling off the plane) puts you back at the landing
  spot with full HP. No checkpoints yet — that's a later phase.
- **Rusher** (red capsule): hunts you down at 5 m/s and swings — windup,
  strike, recover — for 10 damage. 40 HP (2 wrench swings / 4 bolts).
- **Shooter** (purple capsule): keeps ~10 m away, backs off if you get
  within 4 m, and fires slow red bolts (10 damage) you can dodge or
  outrun. 30 HP. Its bolts die on walls, so use the crates as cover.
- **Both enemies run on real LimboAI behavior trees** — authored as text
  resources with custom chase / flee / strike / volley tasks, exactly the
  architecture the full slice needs. Adding enemy types from here is mostly
  new trees plus tuning.
- **Health pickups:** two spinning green crosses on the plane, +25 HP on
  touch, ignored while you're at full health.
- **Test plane roster:** 2 rushers, 1 shooter, 1 practice dummy, 2 pickups.
- **Tests:** six headless tests now gate every commit — camera, combat
  pipeline, lock-on, pickups, and one per enemy proving the AI actually
  chases/keeps range and lands hits with zero scripted movement.

## Bug found and fixed along the way

Spawning a body at the tree origin and positioning it afterwards let
physics depenetrate it against whatever stood there — in the worst case the
hero got carried across the map on a rusher's head. Spawn code now always
positions before adding to the tree; rule documented in CLAUDE.md.

## Judgment calls

1. Enemy damage is deliberately gentle (10 per hit vs your 100 HP) — first
   pass is about readability, not challenge. All numbers are exports.
2. The shooter leads nothing and aims at where you are — dodgeable on
   purpose at 14 m/s bolt speed.
3. Enemies collide with you and each other but never hit their own faction
   (collision layers enforce it).
4. Respawn is instant with no death screen — greybox.
5. New `pickups/` folder for pickup scenes (wasn't in the original list).

## Controls — unchanged from Phase 2

WASD run · Space jump/double-jump · mouse orbit · LMB fire · F wrench ·
wheel/d-pad cycle weapon · Q lock-on (Q again cycles targets) · Esc frees
the cursor.

Launch: `C:/MrC/tools/godot.exe --path C:/MrC/MrC_Slice`

## Playtest checklist

- Getting hit: can you always tell when and by what? i-frames feel fair?
  - [ ] …
- Rusher: scary, pushover, or annoying? swing readable enough to dodge?
  - [ ] …
- Shooter: fun to close in on? bolts dodgeable? does it kite too well?
  - [ ] …
- Fighting with lock-on vs without: which did you actually use?
  - [ ] …
- Health pickups: noticed them? timing of needing one felt right?
  - [ ] …
- Death/respawn: confusing or fine?
  - [ ] …
- Anything broken or weird:
  - [ ] …

## Next session

Feel-tuning from this checklist, then: turret + swarmling enemies, the
remaining two weapons (spread scattergun, lobbed grenade-bot), and bolts
currency dropping from kills with magnetize-to-player.
