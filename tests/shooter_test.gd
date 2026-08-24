extends Node

## Headless check: a shooter must hit the hero with a bolt from range
## under behavior-tree control, while keeping its distance.
## Run: godot --headless --path . res://tests/shooter_test.tscn

const HERO_SCENE: PackedScene = preload("res://player/hero.tscn")
const SHOOTER_SCENE: PackedScene = preload("res://enemies/shooter.tscn")

var _hero: Hero
var _hero_health: HealthComponent
var _shooter: ShooterEnemy
var _min_distance: float = 1000.0
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
	_hero_health = _hero.get_node("HealthComponent")

	_shooter = SHOOTER_SCENE.instantiate()
	_shooter.position = Vector3(10, 0.1, 0)
	add_child(_shooter)


func _physics_process(_delta: float) -> void:
	_ticks += 1
	_min_distance = minf(_min_distance, _shooter.flat_distance_to(_hero.global_position))
	if _ticks < 360:
		return
	var hit_landed: bool = _hero_health.current_health < _hero_health.max_health
	var kept_distance: bool = _min_distance > 3.0
	print("hero HP %d (want < 100), shooter min distance %.2f m (want > 3)" % [
		_hero_health.current_health, _min_distance
	])
	if hit_landed and kept_distance:
		print("PASS: shooter AI")
		get_tree().quit(0)
	else:
		print("FAIL: shooter AI")
		get_tree().quit(1)
