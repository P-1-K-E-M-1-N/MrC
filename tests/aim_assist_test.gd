extends Node

## Headless check: holding attack with an enemy off-angle nearby must
## auto-face and hit it — no camera aiming involved.
## Run: godot --headless --path . res://tests/aim_assist_test.tscn

const HERO_SCENE: PackedScene = preload("res://player/hero.tscn")
const DUMMY_SCENE: PackedScene = preload("res://enemies/target_dummy.tscn")

var _hero: Hero
var _dummy: TargetDummy
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

	# 45 degrees off the camera line, inside wrench reach.
	_dummy = DUMMY_SCENE.instantiate()
	_dummy.position = Vector3(1.1, 0, -1.1)
	add_child(_dummy)
	# Beefed up so repeated swings can't kill it mid-test.
	var dummy_health: HealthComponent = _dummy.get_node("HealthComponent")
	dummy_health.max_health = 1000
	dummy_health.current_health = 1000


func _physics_process(_delta: float) -> void:
	_ticks += 1
	if _ticks == 10:
		Input.action_press("attack")
	if _ticks < 120:
		return
	Input.action_release("attack")
	var hp: int = _dummy.get_node("HealthComponent").current_health
	var visual: Node3D = _hero.get_node("Visual")
	var wanted_yaw: float = atan2(-1.1, 1.1)
	var yaw_error: float = absf(angle_difference(visual.global_rotation.y, wanted_yaw))
	print("dummy HP %d (want <= 950), facing error %.2f rad (want < 0.1)" % [hp, yaw_error])
	if hp <= 950 and yaw_error < 0.1:
		print("PASS: aim assist")
		get_tree().quit(0)
	else:
		print("FAIL: aim assist")
		get_tree().quit(1)
