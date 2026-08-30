extends Node

## Headless softlock checks: dying inside a sealed arena re-arms it, and
## an enemy knocked off the world despawns so the arena can still clear.
## Run: godot --headless --path . res://tests/hardening_test.tscn

const HERO_SCENE: PackedScene = preload("res://player/hero.tscn")
const RUSHER_SCENE: PackedScene = preload("res://enemies/rusher.tscn")
const ARENA_SCRIPT: Script = preload("res://levels/gadgets/arena.gd")

var _hero: Hero
var _rusher: EnemyBase
var _arena: ArenaVolume
var _gate: StaticBody3D
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

	# Hero starts (and therefore respawns) outside the arena volume.
	_hero = HERO_SCENE.instantiate()
	_hero.position = Vector3(0, 0.1, 30)
	add_child(_hero)

	_rusher = RUSHER_SCENE.instantiate()
	_rusher.position = Vector3(0, 0.1, -3)
	add_child(_rusher)

	var arena_node: Area3D = Area3D.new()
	arena_node.set_script(ARENA_SCRIPT)
	_arena = arena_node
	_arena.collision_layer = 0
	_arena.collision_mask = 2
	_gate = StaticBody3D.new()
	_gate.name = "Gate"
	_arena.add_child(_gate)
	var volume_shape: CollisionShape3D = CollisionShape3D.new()
	var volume_box: BoxShape3D = BoxShape3D.new()
	volume_box.size = Vector3(16, 10, 15)
	volume_shape.shape = volume_box
	volume_shape.position = Vector3(0, 3, 0)
	_arena.add_child(volume_shape)
	_arena.gate_paths = [NodePath("Gate")]
	_arena.enemy_paths = [NodePath("../" + str(_rusher.name))]
	add_child(_arena)


func _physics_process(_delta: float) -> void:
	_ticks += 1
	match _ticks:
		20:
			_teleport(Vector3(0, 0.5, 0))
		50:
			_check(_gate.collision_layer == 1, "arena sealed on entry")
			_hero.get_node("HealthComponent").take_damage(999999)
		80:
			_check(_gate.collision_layer == 0, "gates dropped after hero death")
			_check(_hero.global_position.z > 20.0, "hero respawned outside")
			_teleport(Vector3(0, 0.5, 0))
		110:
			_check(_gate.collision_layer == 1, "arena re-armed on re-entry")
			_rusher.global_position = Vector3(0, -30, 0)
		150:
			_check(not is_instance_valid(_rusher), "fallen enemy despawned")
			_check(_gate.collision_layer == 0, "arena cleared via fallen enemy")
			if _failures.is_empty():
				print("PASS: hardening")
				get_tree().quit(0)
			else:
				print("FAIL: ", ", ".join(_failures))
				get_tree().quit(1)


func _teleport(point: Vector3) -> void:
	_hero.global_position = point
	_hero.velocity = Vector3.ZERO


func _check(condition: bool, label: String) -> void:
	print(("ok: " if condition else "FAILED: ") + label)
	if not condition:
		_failures.append(label)
