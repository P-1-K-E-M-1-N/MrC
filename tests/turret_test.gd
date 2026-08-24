extends Node

## Headless check: a turret shoots the hero from range under BT control.
## Run: godot --headless --path . res://tests/turret_test.tscn

const HERO_SCENE: PackedScene = preload("res://player/hero.tscn")
const TURRET_SCENE: PackedScene = preload("res://enemies/turret.tscn")

var _hero: Hero
var _turret: ShooterEnemy
var _ticks: int = 0


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

	_turret = TURRET_SCENE.instantiate()
	_turret.position = Vector3(10, 0.1, 0)
	add_child(_turret)


func _physics_process(_delta: float) -> void:
	_ticks += 1
	if _ticks < 360:
		return
	var hp: int = _hero.get_node("HealthComponent").current_health
	var stayed_put: bool = _turret.flat_distance_to(Vector3(10, 0, 0)) < 0.5
	print("hero HP %d (want < 100), turret stayed put: %s" % [hp, stayed_put])
	if hp < 100 and stayed_put:
		print("PASS: turret")
		get_tree().quit(0)
	else:
		print("FAIL: turret")
		get_tree().quit(1)
