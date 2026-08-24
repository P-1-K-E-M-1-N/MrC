extends Node

## Headless check: entering an arena raises its gate, killing the last
## enemy drops it, fires cleared, and pays out bolts.
## Run: godot --headless --path . res://tests/arena_test.tscn

const HERO_SCENE: PackedScene = preload("res://player/hero.tscn")
const RUSHER_SCENE: PackedScene = preload("res://enemies/rusher.tscn")
const BOLT_SCENE: PackedScene = preload("res://pickups/bolt_pickup.tscn")
const ARENA_SCRIPT: GDScript = preload("res://levels/gadgets/arena.gd")

var _hero: Hero
var _rusher: EnemyBase
var _arena: Area3D
var _gate: StaticBody3D
var _cleared: bool = false
var _ticks: int = 0
var _failures: Array[String] = []


func _ready() -> void:
	var floor_body: StaticBody3D = StaticBody3D.new()
	var floor_shape: CollisionShape3D = CollisionShape3D.new()
	var floor_box: BoxShape3D = BoxShape3D.new()
	floor_box.size = Vector3(200, 1, 200)
	floor_shape.shape = floor_box
	floor_body.add_child(floor_shape)
	add_child(floor_body)
	floor_body.position = Vector3(0, -0.5, 0)

	_hero = HERO_SCENE.instantiate()
	_hero.position = Vector3(30, 0.1, 0)
	add_child(_hero)

	_rusher = RUSHER_SCENE.instantiate()
	_rusher.name = "Rusher"
	_rusher.position = Vector3(0, 0.1, -5)
	add_child(_rusher)

	_arena = Area3D.new()
	_arena.set_script(ARENA_SCRIPT)
	_arena.collision_mask = 2
	var volume_shape: CollisionShape3D = CollisionShape3D.new()
	var volume_box: BoxShape3D = BoxShape3D.new()
	# Trigger is smaller than the arena so the hero is well past the
	# entrance gate before it seals (gate sits at z 11.5).
	volume_box.size = Vector3(16, 10, 15)
	volume_shape.shape = volume_box
	volume_shape.position = Vector3(0, 3, 0)
	_arena.add_child(volume_shape)

	_gate = StaticBody3D.new()
	_gate.name = "GateIn"
	var gate_shape: CollisionShape3D = CollisionShape3D.new()
	var gate_box: BoxShape3D = BoxShape3D.new()
	gate_box.size = Vector3(8, 4, 0.4)
	gate_shape.shape = gate_box
	_gate.add_child(gate_shape)
	_gate.position = Vector3(0, 2, 11.5)
	_arena.add_child(_gate)

	var gate_list: Array[NodePath] = [NodePath("GateIn")]
	var enemy_list: Array[NodePath] = [NodePath("../Rusher")]
	_arena.set("gate_paths", gate_list)
	_arena.set("enemy_paths", enemy_list)
	_arena.set("bolt_reward_scene", BOLT_SCENE)
	add_child(_arena)
	_arena.connect("cleared", func() -> void: _cleared = true)


func _physics_process(_delta: float) -> void:
	_ticks += 1
	match _ticks:
		20:
			_check(_gate.collision_layer == 0 and not _gate.visible,
				"gate down before hero enters")
			_hero.global_position = Vector3(0, 0.1, 10)
			_hero.velocity = Vector3.ZERO
		40:
			_check(_gate.collision_layer == 0 and not _gate.visible,
				"gate stays down at the entrance line")
			_hero.global_position = Vector3(0, 0.1, 5)
			_hero.velocity = Vector3.ZERO
		60:
			_check(_gate.collision_layer == 1 and _gate.visible,
				"gate up after hero enters")
			_rusher.health.take_damage(999)
		120:
			_check(_gate.collision_layer == 0 and not _gate.visible,
				"gate down after arena cleared")
			_check(_cleared, "cleared signal fired")
			var bolts_found: bool = false
			for child in get_children():
				if child is BoltPickup:
					bolts_found = true
			_check(bolts_found, "reward bolts spawned")
			if _failures.is_empty():
				print("PASS: arena gating")
				get_tree().quit(0)
			else:
				print("FAIL: ", ", ".join(_failures))
				get_tree().quit(1)


func _check(condition: bool, label: String) -> void:
	print(("ok: " if condition else "FAILED: ") + label)
	if not condition:
		_failures.append(label)
