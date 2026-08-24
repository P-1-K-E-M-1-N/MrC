extends Node

## Headless check of the R&C camera rule: holding fire on a flanking
## enemy turns the CHARACTER onto it (smoothly), while the CAMERA yaw
## stays planted — the control frame must not rotate mid-combat.
## Run: godot --headless --path . res://tests/combat_camera_test.tscn

const HERO_SCENE: PackedScene = preload("res://player/hero.tscn")
const DUMMY_SCENE: PackedScene = preload("res://enemies/target_dummy.tscn")

var _hero: Hero
var _rig: CameraRig
var _dummy: TargetDummy
var _max_camera_drift: float = 0.0
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
	_rig = _hero.get_node("CameraRig")

	# ~60 degrees off the camera line, inside the aim-assist cone.
	_dummy = DUMMY_SCENE.instantiate()
	_dummy.position = Vector3(2.6, 0, -1.5)
	add_child(_dummy)
	var dummy_health: HealthComponent = _dummy.get_node("HealthComponent")
	dummy_health.max_health = 100000
	dummy_health.current_health = 100000


func _physics_process(_delta: float) -> void:
	_ticks += 1
	if _ticks == 10:
		Input.action_press("attack")
	if _ticks > 10:
		_max_camera_drift = maxf(_max_camera_drift, absf(angle_difference(_rig.rotation.y, 0.0)))
	if _ticks < 170:
		return
	Input.action_release("attack")
	var visual: Node3D = _hero.get_node("Visual")
	var wanted_yaw: float = atan2(-2.6, 1.5)
	var facing_error: float = absf(angle_difference(visual.global_rotation.y, wanted_yaw))
	print("camera drift %.3f rad (want < 0.1), facing error %.3f rad (want < 0.15)" % [
		_max_camera_drift, facing_error
	])
	if _max_camera_drift < 0.1 and facing_error < 0.15:
		print("PASS: combat camera stability")
		get_tree().quit(0)
	else:
		print("FAIL: combat camera stability")
		get_tree().quit(1)
