# MrC — Phase 6 Report: Combat Feel + Pause & Quick-Select

Session date: 2026-08-23 · Status: **all four requests in, plus the polish phase**

## Your requests

1. **Lock-on chains kills** — when your locked target dies, the lock hops
   to the nearest remaining enemy automatically; it only drops when
   nothing is left in range (or the target escapes past 18 m).
2. **Short enemies actually get hit now** — every enemy declares its own
   aim height (swarmlings 0.4 m, humanoids 0.9, turret head 1.2), and
   guns fire full-3D at that point, so bolts and pellets pitch DOWN at
   swarmlings instead of sailing over their heads. The wrench swing
   sphere also sits lower and reaches bigger, covering ankle-height
   targets.
3. **Damage feedback** — floating damage numbers pop off everything you
   hit (enemies, crates, the practice dummy — and you, when you take a
   hit). They rise and fade. Proper hit VFX/sound is still a later
   polish item; numbers make damage readable today.
4. **Jumping toned down by half** — jump 4.5 → 2.25 m, double jump
   3.2 → 1.6 m. The flip burst and jump pads are unchanged. Note: the
   platforming gaps were built for the old jump — if any gap now feels
   unfair, that's tuning, tell me which one.

## The next phase: pause + quick-select

- **Esc now opens a real pause menu** — game freezes, cursor frees,
  Resume / Quit buttons. (Esc used to just release the cursor.)
- **Number keys 1–4 equip weapons directly**: 1 Wrench, 2 Blaster,
  3 Scatter Snapper, 4 Lob-Bot. The HUD bottom line shows the numbered
  weapon strip with your current pick in brackets. Mouse wheel and
  d-pad still cycle. (A radial wheel with icons belongs to the art
  pass; the number row is the fast greybox equivalent.)

## Verification

All thirteen headless tests pass — the lock-on test now asserts the
retarget-on-kill hop, and the aim-assist test still proves hits land
with zero camera input.

## Still open for future sessions

Arena gating (lock you in until the arena is cleared), hit/death
VFX and audio, the radial weapon wheel visual, GitHub publish
(needs your login), and difficulty tuning from your next run.
