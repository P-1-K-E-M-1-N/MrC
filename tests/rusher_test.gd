extends Node

## Headless check: a rusher must chase the hero across the floor under
## behavior-tree control and land at least one melee hit.
## Run: godot --headless --path . res://tests/rusher_test.tscn

const HERO_SCENE: PackedScene = preload("res://player/hero.tscn")
const RUSHER_SCENE: PackedScene = preload("res://enemies/rusher.tscn")

var _hero: Hero
var _hero_health: HealthComponent
var _rusher: EnemyBase
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
	add_child(_hero)
	_hero.global_position = Vector3(0, 0.1, 0)
	_hero_health = _hero.get_node("HealthComponent")

	_rusher = RUSHER_SCENE.instantiate()
	# Position before entering the tree: spawning at the origin would
	# momentarily overlap the hero and physics would ride them apart.
	_rusher.position = Vector3(8, 0.1, 0)
	add_child(_rusher)


func _physics_process(_delta: float) -> void:
	_ticks += 1
	if _ticks < 300:
		return
	var distance: float = _rusher.flat_distance_to(_hero.global_position)
	var closed_in: bool = distance < 3.0
	var landed_hit: bool = _hero_health.current_health < _hero_health.max_health
	print("rusher distance %.2f m (want < 3), hero HP %d (want < 100)" % [
		distance, _hero_health.current_health
	])
	if closed_in and landed_hit:
		print("PASS: rusher AI")
		get_tree().quit(0)
	else:
		print("FAIL: rusher AI")
		get_tree().quit(1)
