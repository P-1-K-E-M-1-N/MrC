extends Node

## Headless check: a damaged hero standing on a health pickup gets healed
## and the pickup is consumed; a full-HP hero would not consume it.
## Run: godot --headless --path . res://tests/pickup_test.tscn

const HERO_SCENE: PackedScene = preload("res://player/hero.tscn")
const PICKUP_SCENE: PackedScene = preload("res://pickups/health_pickup.tscn")

var _hero: Hero
var _health: HealthComponent
var _pickup: HealthPickup
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
	_health = _hero.get_node("HealthComponent")

	_pickup = PICKUP_SCENE.instantiate()
	add_child(_pickup)
	_pickup.global_position = Vector3(0, 1, 0)


func _physics_process(_delta: float) -> void:
	_ticks += 1
	if _ticks == 5:
		_health.take_damage(50)
	if _ticks < 60:
		return
	var healed: bool = _health.current_health == 75
	var consumed: bool = not is_instance_valid(_pickup)
	print("hero HP %d (want 75), pickup consumed: %s" % [_health.current_health, consumed])
	if healed and consumed:
		print("PASS: health pickup")
		get_tree().quit(0)
	else:
		print("FAIL: health pickup")
		get_tree().quit(1)
