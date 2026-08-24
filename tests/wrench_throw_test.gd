extends Node

## Headless check: the thrown wrench damages a dummy on the way out,
## returns to the hero, blocks swings while airborne, and restores after.
## Run: godot --headless --path . res://tests/wrench_throw_test.tscn

const HERO_SCENE: PackedScene = preload("res://player/hero.tscn")
const DUMMY_SCENE: PackedScene = preload("res://enemies/target_dummy.tscn")

var _hero: Hero
var _dummy: TargetDummy
var _wrench: TorqueWrench
var _ticks: int = 0
var _failures: Array[String] = []


func _ready() -> void:
	var floor_body: StaticBody3D = StaticBody3D.new()
	var floor_shape: CollisionShape3D = CollisionShape3D.new()
	var floor_box: BoxShape3D = BoxShape3D.new()
	floor_box.size = Vector3(100, 1, 100)
	floor_shape.shape = floor_box
	floor_body.add_child(floor_shape)
	add_child(floor_body)
	floor_body.position = Vector3(0, -0.5, 0)

	_hero = HERO_SCENE.instantiate()
	_hero.position = Vector3(0, 0.1, 0)
	add_child(_hero)
	_dummy = DUMMY_SCENE.instantiate()
	_dummy.position = Vector3(0, 0, -5)
	add_child(_dummy)


func _physics_process(_delta: float) -> void:
	_ticks += 1
	match _ticks:
		10:
			var holder: WeaponHolderComponent = _hero.get_node("WeaponHolderComponent")
			_wrench = holder.weapons[holder.melee_index]
			_check(_wrench.try_throw(_hero.get_node("Visual")), "throw accepted")
		30:
			_check(_wrench.is_thrown, "wrench is airborne")
			_check(not _wrench.try_fire(), "swing blocked while thrown")
		40:
			_check(_dummy.get_node("HealthComponent").current_health == 25,
				"outbound hit for 25")
		150:
			_check(not _wrench.is_thrown, "wrench returned")
			_check(_wrench.try_fire(), "swing works after return")
			if _failures.is_empty():
				print("PASS: wrench throw")
				get_tree().quit(0)
			else:
				print("FAIL: ", ", ".join(_failures))
				get_tree().quit(1)


func _check(condition: bool, label: String) -> void:
	print(("ok: " if condition else "FAILED: ") + label)
	if not condition:
		_failures.append(label)
