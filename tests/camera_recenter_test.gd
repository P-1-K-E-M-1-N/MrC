extends Node

## Headless check: with no camera input, the rig yaw must converge behind
## the hero's facing direction within a few seconds.
## Run: godot --headless --path . res://tests/camera_recenter_test.tscn

const HERO_SCENE: PackedScene = preload("res://player/hero.tscn")
const TARGET_YAW: float = PI * 0.5
const TICKS_TO_WAIT: int = 180

var _rig: CameraRig
var _ticks: int = 0


func _ready() -> void:
	var hero: CharacterBody3D = HERO_SCENE.instantiate()
	add_child(hero)
	_rig = hero.get_node("CameraRig")
	hero.get_node("Visual").rotation.y = TARGET_YAW


func _physics_process(_delta: float) -> void:
	_ticks += 1
	if _ticks < TICKS_TO_WAIT:
		return
	var error: float = absf(angle_difference(_rig.rotation.y, TARGET_YAW))
	if error < 0.05:
		print("PASS: camera recentered, error %.4f rad" % error)
		get_tree().quit(0)
	else:
		print("FAIL: camera yaw %.3f, wanted %.3f" % [_rig.rotation.y, TARGET_YAW])
		get_tree().quit(1)
