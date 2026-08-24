# MrC — Phase 5 Report: Your Three Requests + The Real Level

Session date: 2026-08-23 · Status: **the slice is now a playable planet, start to finish**

## Your three requests

1. **Camera sits higher** — it now rests ~12° above, looking down at the
   action, slightly farther back. You can still orbit freely; this is just
   the default angle.
2. **Directional air flip** — jump, then jump again **while holding a
   direction**: you get a fast burst that way (10 m/s, briefly beating the
   run cap) with a barrel roll for sideways input and a front/back flip
   otherwise. Air-jump with no direction held is still the plain double
   jump. Great for crossing the new platforming gaps.
3. **Throwable wrench** — **right mouse** (or left trigger) hurls the
   wrench ~10 m: it damages everything on the way out, then boomerangs
   back to your hand and damages again on the return. You can't swing
   while it's airborne. 25 damage per pass, no ammo cost.

## Phase 5: planet_01 — the actual level

The game now boots into a linear planet over a void (falling = respawn at
your last checkpoint):

**Landing pad** (crates to smash) → corridor → **Arena 1** (2 rushers +
3 swarmlings) → **floating platform gaps** with a jump pad up to the
higher plateau → **Arena 2** (2 shooters + turret + rusher) → a bridge
**blockaded with breakable crates** → **Arena 3** (2 turrets, shooter,
2 rushers, 4 swarmlings) → **vendor plaza** → **exit ring** (slice
complete screen).

- **Checkpoints** (grey rings, turn green) at each arena move your
  respawn forward.
- **Vendor kiosk**: stand close, press **E** — full HP + all ammo for
  20 bolts. It tells you if you're broke.
- **Breakable crates** pop from any attack and scatter bolts.
- The old test plane still exists at `levels/test_plane.tscn` as a
  sandbox.

## Bug found while testing

The jump pad scene was missing its script attachment — my gadget test
caught it because the typed cast failed loudly, taking half the test
setup down with it. One-line fix; the test now proves pad launch, crate
drops, checkpoint respawn, and the vendor transaction end to end.

## Verification

Twelve headless tests green (throw + gadgets are new), planet loads
clean headless and windowed.

## Controls (full, current)

WASD run · Space jump / air-flip with direction · mouse orbit ·
LMB fire · **RMB throw wrench** · F swing wrench · wheel cycle weapons ·
Q lock-on · **E interact (vendor)** · Esc free cursor

## Playtest checklist

- Camera default angle: right height? want more/less?
  - [ ] …
- Air flip: does the burst distance feel good? roll animation read well?
  - [ ] …
- Wrench throw: range/return speed right? satisfying?
  - [ ] …
- The level: too long/short? difficulty ramp fair? any spot confusing?
  - [ ] …
- Platforming gaps: fair with double jump + flip? jump pad launch right?
  - [ ] …
- Checkpoints & respawn: placed well? losing progress anywhere?
  - [ ] …
- Vendor: worth the bolts? price right?
  - [ ] …
- Anything broken or weird:
  - [ ] …

## What remains for the full slice

Feel-tuning from your notes, then polish targets: pause menu (pause +
quit only), weapon quick-select wheel, arena gating if you want combat
to lock you in, hit/death VFX and audio pass, and the GitHub publish
step whenever you want the repo online.
