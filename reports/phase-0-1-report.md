# MrC — Phase 0 + 1 Report

Session date: 2026-08-23 · Lead TD session · Status: **ready for playtest**

## What was built

### Phase 0 — Scaffolding
- **Godot 4.7.2-stable** installed to `C:\MrC\tools\godot.exe` (extracted from the
  official zip already in your Downloads folder — the bare `.exe` there was a
  1-byte placeholder, the real build was inside `...win64.exe.zip`).
- Project at `C:\MrC\MrC_Slice\`, Forward+ renderer, full folder structure
  (`player/ components/ weapons/ enemies/ levels/ ui/ vfx/ audio/ assets/ tests/`
  plus `reports/`).
- Git repo on branch `main` with a Godot `.gitignore`; 8 commits, one feature each.
- `CLAUDE.md` rulebook: Godot 4 API only, static typing, component architecture,
  headless verification rule, commit convention, slice non-goals.
- **LimboAI v1.8.1** GDExtension (official release built against Godot 4.7.2)
  installed under `addons/limboai` for future enemy behavior trees. Loads clean.
- `levels/test_plane.tscn` main scene: 60×60 floor, two crates, a low platform
  (top at 2 m), a high platform (top at 3.5 m), a pillar, sun + procedural sky.

### Phase 1 — Greybox character controller
- **GDQuest seeding verdict:** their Godot 4 third-person controller is maintained
  on 4.7 (checked its `project.godot`), so I adopted its proven *patterns* —
  camera-basis-relative input, SpringArm3D rig, captured-mouse orbit, slerp
  facing — but wrote our implementation from scratch: theirs is monolithic,
  uses floaty lerp acceleration, and lacks double-jump/coyote/buffering.
- `player/hero.tscn`: `CharacterBody3D` + capsule, orange greybox mesh with a
  **yellow nose block** showing facing. Components as children per CLAUDE.md:
  `InputComponent`, `MovementComponent`, `CameraRig`, stub `HealthComponent`,
  stub `WeaponHolderComponent`.
- Movement: camera-relative run 7 m/s, accel 40 m/s², decel 60 m/s²,
  gravity 1.8× (17.64 m/s²), jump to ~4.5 m apex, air jump to ~3.2 m
  (resets on landing), coyote 0.12 s, jump buffer 0.15 s.
- Camera: SpringArm3D orbit (mouse + right stick), pitch clamped −60°…+75°,
  lagged follow, spring-arm wall collision.
- Input map: WASD/Space + left stick/bottom face button/right stick.

## Deviations & judgment calls (all tunable — that's what the playtest is for)

1. **Jump apex 4.5 m taken literally** from the spec. It's a big, generous jump
   (~0.7 s to apex even under heavy gravity). If it reads floaty, we drop
   `jump_height` — it's a single export on `MovementComponent`.
2. **Air jump height 3.2 m** — spec said "slightly weaker"; ~70% felt right on paper.
3. **Double-jump priority:** a mid-air jump press fires the air jump instantly;
   the buffer catches pre-landing presses once the air jump is spent. Standard
   platformer feel; tell me if a pre-landing press "wastes" your double jump.
4. **GitHub repo not created** — no `gh` CLI on this machine and I won't handle
   your login. One manual step below.
5. Test plane platform heights chosen so: low platform = single jump,
   high platform = needs the double jump. Use them as feel probes.
6. Extra `reports/` folder added at project root for these handoffs.

## Publish to GitHub (one manual step)

Create an empty repo named `MrC` on github.com (no README), then run:

```bash
cd /c/MrC/MrC_Slice && git remote add origin https://github.com/YOUR_USERNAME/MrC.git && git push -u origin main
```

(Or install `gh` CLI and I'll do it next session.)

## How to launch and play

Double-click `C:\MrC\tools\godot.exe`, import/open `C:\MrC\MrC_Slice\project.godot`,
press **F5**. Or from a terminal:

```bash
C:/MrC/tools/godot.exe --path C:/MrC/MrC_Slice
```

| Input | Action |
|---|---|
| **W A S D** / left stick | Run (camera-relative) |
| **Space** / bottom face button (A/Cross) | Jump — press again in air for double jump |
| **Mouse** / right stick | Orbit camera |
| **Esc** | Release the mouse cursor (click any mouse button to recapture) |
| Close window / editor Stop | Quit |

The orange capsule is you; the yellow block is your nose (facing direction).
Low platform = one jump. High platform = jump + double jump.

## Playtest checklist — fill this in, it drives the next session

- Jump feel: floaty / snappy / heavy?
  - [ ] …
- Double-jump: satisfying or free-feeling?
  - [ ] …
- Camera: fights me? too slow/fast? clips anywhere?
  - [ ] …
- Run speed: sluggish / right / slippery?
  - [ ] …
- Anything that felt broken or weird:
  - [ ] …

## Tuning pass 1 (2026-08-23, from Nick's first playtest)

- **"Heavier jump"** → gravity 1.8× → 2.0×, plus 1.3× extra gravity while
  falling. Apex heights unchanged (jump velocity is derived from height), so
  the same platforms are reachable — the arc is just quicker and punchier.
- **"Pause between jumps"** → 0.18 s lockout after any jump before the air
  jump can fire (`double_jump_delay` on MovementComponent).
- **"Camera should snap behind me"** → auto-recenter: after 0.9 s without
  camera input, while running, yaw eases behind the hero's facing. Mouse or
  stick input always overrides it instantly. Toggle/tune on CameraRig
  (`auto_recenter`, `recenter_delay`, `recenter_speed`).
- **"Looks blocky"** → intentional greybox; art direction pass comes after
  combat is proven. Not addressed.

## Next session (after your feedback)

Feel-tuning pass from this checklist, then **Phase 2: combat core**
(wrench-style melee + first gun, WeaponHolderComponent goes real).
