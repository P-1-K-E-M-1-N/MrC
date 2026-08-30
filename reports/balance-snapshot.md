# Balance Snapshot — 2026-08-24

Numbers computed from live scene data, not guesses. This is the reference
sheet for Nick's next playthrough; feel notes beat spreadsheet notes.

## Weapon DPS (after this pass's tuning)

| Weapon | Damage math | DPS | Range | Ammo |
|---|---|---|---|---|
| Torque Wrench (swing) | 25 per 0.45 s | ~55 | melee | free |
| Wrench throw | 25 out + 25 back | burst | 10 m boomerang | free |
| Pip Blaster | 10 per 0.15 s *(was 0.125)* | ~66 *(was 80)* | long | 200 |
| Scatter Snapper | 6×13 per 0.9 s *(was 6×8)* | ~87 point-blank *(was 53)* | ≤12 m, falls off | 40 |
| Lob-Bot | 30 AoE per 1.0 s | 30/target, multi-hit | lobbed arc | 12 |

**The change:** the blaster (safe, long range) out-damaged the scattergun
(risky, close range) — the safe gun strictly dominated. Now the hierarchy
is: scattergun highest but you must be in melee-adjacent danger; blaster
solid sustained; wrench free but riskiest; Lob-Bot for packs.

## Time-to-kill (shots/swings needed)

| | Swarmling 10 HP | Shooter 30 HP | Rusher 40 HP | Turret 60 HP |
|---|---|---|---|---|
| Wrench 25 | 1 | 2 | 2 | 3 |
| Blaster 10 | 1 | 3 | 4 | 6 |
| Scatter (full 78) | 1 | 1 | 1 | 1 |
| Grenade 30 AoE | 1 | 1 | 2 | 2 |

Scattergun one-shotting a rusher point-blank is intentional shotgun
fantasy; it costs 1/40 of its ammo and standing in rusher range.

## Incoming damage (hero: 100 HP, 0.6 s i-frames)

Rusher melee 10 · swarmling bite 5 · shooter/turret bolt 10.
With i-frames, worst sustained pressure ≈ 16 dmg/s → ~6 s to die in a
bad spot; heal 25 per pickup, full refill at vendor for 20 bolts.

## Open questions for the playtest (feel > math)

1. Does Arena 2 (shooters + turret at range) feel harder than Arena 3
   (bigger but melee-heavy)? The math says maybe — ranged pressure is
   harder to dodge than chasers.
2. Is 20 bolts for a vendor refill trivial? A full clear collects ~40+.
3. Blaster at 6.7 shots/s — still fun, or does it feel nerfed?
4. Lob-Bot's 12 ammo — hoarded or spent?
