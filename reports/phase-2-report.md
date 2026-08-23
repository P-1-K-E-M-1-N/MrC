# MrC — Phase 2 Report: Combat Core

Session date: 2026-08-23 · Status: **ready for playtest**

## Fixed from your last playtest

- **Camera auto-recenter now works.** Root cause: I had gated it on "hero is
  currently running", so the natural case — stop moving, wait, expect the
  camera to swing behind you — never fired. The gate is gone; recenter engages
  any time you leave the camera alone for 0.9 s. There's now an automated
  headless regression test for it in `tests/`.

## What was built (combat core)

- **Damage pipeline:** `HitboxComponent` (melee, one hit per target per swing)
  and `HurtboxComponent` → `HealthComponent`. Named collision layers:
  world / player / enemy / hurtbox / attack.
- **Weapon system:** `Weapon` base class (ammo, fire cadence, equip visibility)
  with `WeaponHolderComponent` instancing weapons into a hand socket on the hero.
- **Torque Wrench** (melee): 0.3 s arc swing, 25 damage, infinite use. Always
  available on the melee button even with a gun equipped.
- **Pip Blaster** (first gun): 8 shots/s, 10 damage glowing bolts, 200 ammo.
  Bolts die on walls or after 3 s.
- **Aiming model:** any attack snaps the hero to face wherever the camera is
  pointing, so you aim with the camera like a reticle.
- **Target dummies:** three green blocks near spawn, 50 HP each — squash when
  hit, vanish when destroyed. (Real enemies with LimboAI brains are Phase 3.)
- **Greybox HUD** top-left: HP, weapon name, ammo.
- **Tests:** headless combat test fires a real bolt + real wrench swing at
  dummies and asserts the HP math; camera recenter test.

## Judgment calls

1. Weapon names are original placeholders: "Torque Wrench", "Pip Blaster" —
   rename freely later.
2. Melee is a dedicated button (R&C-style) *and* the wrench is in the cycle
   rotation; when a gun is equipped, the melee button swings without switching.
3. Damage numbers (25 wrench / 10 bolt / 50 HP dummies): 2 swings or 5 bolts
   per kill — chosen so both weapons feel meaningfully different. All exports.
4. No hero damage intake yet — nothing attacks you until Phase 3 enemies.

## Controls (new ones in bold)

| Input | Action |
|---|---|
| W A S D / left stick | Run |
| Space / bottom face button | Jump, double jump |
| Mouse / right stick | Orbit camera (auto-recenters after 0.9 s) |
| **Left mouse / right trigger** | **Fire equipped weapon (hold for auto-fire)** |
| **F / west face button (X/Square)** | **Wrench swing (always, even with gun out)** |
| **Mouse wheel / d-pad left-right** | **Cycle weapon** |
| Esc | Release mouse cursor |

Launch as before: `C:/MrC/tools/godot.exe --path C:/MrC/MrC_Slice`

## Playtest checklist

- Wrench swing: does the timing/range feel fair? too short/long?
  - [ ] …
- Blaster: fire rate / projectile speed — punchy or pea-shooter?
  - [ ] …
- Aiming: does camera-line aiming feel natural? fighting the auto-recenter?
  - [ ] …
- Weapon switching: wheel/d-pad cycling feel OK?
  - [ ] …
- Camera recenter (retest): working as you expected now?
  - [ ] …
- Anything broken or weird:
  - [ ] …

## Tuning pass 2 (2026-08-23, from Nick's combat playtest)

- **"Swing should commit me"** → attack lockout: a successful wrench swing
  locks all attacking *and* weapon switching for 0.35 s (the swing plus a
  beat of recovery). Guns declare no lockout, so blaster fire stays fluid.
  Movement stays free during the swing (R&C-style); say the word if you want
  a slow-down or root instead. Knob: `attack_lock` on each weapon scene.
- **"Lock onto enemies with Q"** → Z-targeting: **Q** (or right-stick click)
  locks the nearest enemy within 15 m — marked by a spinning red diamond.
  Press **Q again** to flip to the next target; with nothing else to switch
  to, Q unlocks. The lock drops by itself when the target dies or gets more
  than 18 m away. While locked the camera steers onto the target (your mouse
  still controls pitch, and attacks aim at the target automatically).
- Housekeeping: reconciled scene IDs the editor regenerated when you opened
  the project, and added a headless lock-on test (lock, track, cycle,
  release) alongside the existing two.

## Next session

Feel-tuning from this checklist, then **Phase 3: first real enemies**
(melee rusher + ranged shooter on LimboAI behavior trees, hero damage
intake, health pickups).
