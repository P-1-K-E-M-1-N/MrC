# MrC — Phase 4 Report: Full Arsenal & Enemy Roster

Session date: 2026-08-23 · Status: **all 4 weapons + all 4 enemies in**

## Fixed from your playtest

- **Stale lock-on over dead bodies** — the release logic could silently
  skip on freed targets, leaving the red diamond floating at the corpse.
  Fixed with explicit validity tracking; the test now asserts the marker
  actually disappears on kill.
- **Potato → person** — the hero is now an articulated humanoid greybox:
  visored head, torso, jointed arms and legs, with a procedural run cycle
  (limb swing + bob scaled to speed) and a jump pose in the air. Enemies
  keep their simple shapes for now — humanizing them can come with the art
  pass. Shout if the run cycle looks silly at any speed.

## New weapons (cycle with mouse wheel / d-pad)

| Weapon | Feel | Numbers |
|---|---|---|
| Torque Wrench | melee commit | 25 dmg, infinite |
| Pip Blaster | hold-to-spray | 10 dmg, 8/s, 200 ammo |
| **Scatter Snapper** | pump shotgun | 6 pellets × 8 dmg, ~12 m max range, 40 ammo |
| **Lob-Bot** | arcing bomb | ~9 m lob, 3 m blast, 30 dmg, 12 ammo |

## New enemies

- **Turret** (dark pylon, red head): stationary, 60 HP, shoots fast
  volleys at anything within 18 m. Placed far corner of the plane —
  approach with cover or lob grenades.
- **Swarmlings** (small yellow, red eye): 10 HP each, fast, 5-damage
  bites. A pack of five lives on the east side. Scattergun bait.

## Bolts currency

Every enemy death scatters gold bolt rings (1-8 depending on the enemy).
They magnetize to you inside ~4.5 m and the HUD counts them. Nothing to
spend them on yet — the vendor kiosk is a future phase.

## Judgment calls

1. Grenades detonate on contact OR a 2 s fuse — first tuning flight went
   15 m, reined in to ~9 m for an arena-sized lob.
2. Scattergun pellets simply expire mid-air past ~12 m; no damage falloff
   math — range-limiting via lifetime reads cleaner in greybox.
3. Turret reuses the shooter's brain and body with zero move speed — one
   scene, one tree, no new code.
4. Swarmlings body-block each other naturally via physics; no flocking
   code yet. If packs feel clumpy, that's a future boid pass.

## Verification

Ten headless tests pass — the six from before plus scattergun spread
damage, grenade AoE, turret fire-at-range, and swarmling bites with bolt
drops magnetizing into the wallet. Main scene loads clean windowed.

**Restart the game to see Phase 4 content** — the instance from earlier
in the session predates it.

## Playtest checklist

- Scattergun: satisfying point-blank? range feel fair?
  - [ ] …
- Lob-Bot: arc readable? blast radius fair? fuse too long/short?
  - [ ] …
- Turret: threatening or ignorable? fair to approach?
  - [ ] …
- Swarmlings: fun panic or annoying? pack size right?
  - [ ] …
- Bolts: does collecting feel good? magnet range right?
  - [ ] …
- New hero look: readable? run cycle look OK? anything goofy?
  - [ ] …
- Anything broken or weird:
  - [ ] …

## Next session

Feel-tuning from this checklist, then level structure: the real linear
planet layout (landing pad → arenas → traversal), jump pads, breakable
crates, checkpoints, and the vendor kiosk that finally spends your bolts.
