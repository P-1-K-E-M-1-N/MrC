# MrC — Vertical Slice (MrC_Slice)

3D third-person action platformer in the spirit of Ratchet & Clank. Bright,
chunky, saturated sci-fi; wrench-style melee plus wacky guns; light platforming
between combat arenas. All designs are legally distinct originals — never copy
names, silhouettes, or gadget mechanics from existing games.

## Engine & toolchain (non-negotiable)

- **Godot 4.7.x stable** (currently 4.7.2). Executable: `C:\MrC\tools\godot.exe`.
- Renderer: **Forward+** (Vulkan).
- **GDScript with static typing everywhere** — every variable, parameter, and
  return type is annotated. `var speed: float = 7.0`, `func _ready() -> void:`.
- **Godot 4 API only. Godot 3 idioms are forbidden**:
  - `@export` / `@onready` annotations — never `export var` / `onready var`.
  - Signals connect via callables: `some_signal.connect(_on_thing)` — never
    `connect("some_signal", self, "_on_thing")`.
  - `Input.get_vector()`, `CharacterBody3D` + `move_and_slide()` (no-arg,
    uses `velocity` property), `@export_range`, `Callable`, typed arrays.
- Everything lives in **text**: `.tscn`, `.tres`, `.gd`. Author and diff these
  files directly whenever an editor GUI step would block automation.

## Component architecture

Player and enemies are `CharacterBody3D` roots **composed of child component
nodes**, each with a single responsibility:

- `MovementComponent` — velocity, gravity, jumps, acceleration.
- `HealthComponent` — HP, damage intake, death signal.
- `WeaponHolderComponent` — equipped weapon, switching, fire routing.
- `HurtboxComponent` / `HitboxComponent` — damage areas.
- `InputComponent` — translates raw input into intents; only the player has one
  (enemies get intents from AI instead — same movement code, different driver).

Components communicate through **signals and exported node references**, never
by reaching up the tree with `get_parent()` chains. A second character or a
companion must be buildable by recomposing existing components.

`systems/` holds autoload singletons (registered in project.godot) — currently
`GameStats` (run timer, deaths, kills, bolts collected). Keep autoloads rare
and stateless-ish; gameplay logic stays in components.

## Collision layers (bits in parentheses)

1 world (1) · 2 player (2) · 3 enemy (4) · 4 enemy_hurtbox (8) ·
5 player_attack (16) · 6 player_hurtbox (32) · 7 enemy_attack (64).
Player attacks mask enemy hurtboxes; enemy attacks mask player hurtboxes;
neither faction can hit itself. Projectiles also mask world (1) to die on
geometry.

## Spawning rule

Set a node's `position` BEFORE `add_child()`. Adding a body at the tree
origin and moving it afterwards lets physics depenetrate it against
whatever is already there (a body spawned overlapping the hero once
carried the hero across the map as a "platform").

## Enemy AI

Enemies use LimboAI behavior trees: a `BTPlayer` node on the enemy, the
tree authored as a text `.tres` (see `enemies/rusher.tres`), and custom
tasks in `enemies/tasks/` extending `BTAction`/`BTCondition` (`@tool`,
override `_tick`, use `agent` cast to `EnemyBase` and the `player`
blackboard var published by `EnemyBase._ready`). Movement goes through
`EnemyBase.steer/stop/face_point`; tasks never touch velocity directly.

## Verification rule

**No task is done until the project runs headless without script errors:**

```
C:\MrC\tools\godot.exe --headless --path C:\MrC\MrC_Slice --quit-after 5
```

Run it after every sub-feature. Any script error, parse error, or missing
resource in the output means the task is not done. Exit code must be 0.

## Commit convention

- Small commits, one feature per commit.
- Imperative mood messages ("Add double jump", not "Added double jump").
- Commit only when the verification rule above passes.

## Vertical slice scope

One linear planet, ~10–15 minutes: landing pad → Arena 1 → traversal (jump
pads, gaps) → Arena 2 → traversal (breakable crates) → Arena 3 → vendor
kiosk → exit volume. Hero with run/jump/double-jump/orbit camera; 4 weapons
(melee wrench-style, rapid blaster, spread scattergun, lobbed grenade-bot);
4 enemies (rusher, shooter, turret, swarmling) on LimboAI behavior trees;
bolts currency with magnetize, health pickups, checkpoints, one vendor hook.

## Non-goals — never build these in the slice

- Cutscenes or dialogue systems.
- A second planet/level.
- Weapon leveling / XP.
- Save menus beyond checkpoints.
- Settings screens beyond pause + quit.
- Multiple playable characters.
- Bosses.
