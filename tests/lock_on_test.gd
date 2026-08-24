extends Node

## Headless check of the lock-on loop: first press locks the nearest enemy
## and steers the camera yaw at it, second press cycles to the next target,
## and losing the target releases the lock.
## Run: godot --headless --path . res://tests/lock_on_test.tscn

const HERO_SCENE: PackedScene = preload("res://player/hero.tscn")
const DUMMY_SCENE: PackedScene = preload("res://enemies/target_dummy.tscn")

var _hero: CharacterBody3D
var _lock: LockOnComponent
var _rig: CameraRig
var _near_dummy: TargetDummy
var _far_dummy: TargetDummy
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
	add_child(_hero)
	_hero.global_position = Vector3(0, 0.1, 0)
	_lock = _hero.get_node("LockOnComponent")
	_rig = _hero.get_node("CameraRig")

	_near_dummy = DUMMY_SCENE.instantiate()
	add_child(_near_dummy)
	_near_dummy.global_position = Vector3(6, 0, 0)

	_far_dummy = DUMMY_SCENE.instantiate()
	add_child(_far_dummy)
	_far_dummy.global_position = Vector3(0, 0, 8)


func _physics_process(_delta: float) -> void:
	_ticks += 1
	match _ticks:
		10:
			_hero.get_node("InputComponent").lock_on_pressed.emit()
		90:
			_check(_lock.target == _near_dummy, "locked nearest dummy")
			var wanted_yaw: float = atan2(-6.0, 0.0)
			var yaw_error: float = absf(angle_difference(_rig.rotation.y, wanted_yaw))
			_check(yaw_error < 0.1, "camera tracks target (error %.3f rad)" % yaw_error)
			_hero.get_node("InputComponent").lock_on_pressed.emit()
		120:
			_check(_lock.target == _far_dummy, "second press cycles target")
			_far_dummy.queue_free()
		150:
			_check(_lock.target == _near_dummy, "lock retargets nearest on kill")
			_near_dummy.queue_free()
		180:
			_check(not _lock.is_locked(), "lock releases when last target dies")
			_check(not _lock._indicator.visible, "indicator hides when last target dies")
			if _failures.is_empty():
				print("PASS: lock-on")
				get_tree().quit(0)
			else:
				print("FAIL: ", ", ".join(_failures))
				get_tree().quit(1)


func _check(condition: bool, label: String) -> void:
	print(("ok: " if condition else "FAILED: ") + label)
	if not condition:
		_failures.append(label)
