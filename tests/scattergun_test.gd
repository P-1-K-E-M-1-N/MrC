extends Node

## Headless check: one scattergun blast at close range lands multiple
## pellets on a dummy.
## Run: godot --headless --path . res://tests/scattergun_test.tscn

const DUMMY_SCENE: PackedScene = preload("res://enemies/target_dummy.tscn")
const GUN_SCENE: PackedScene = preload("res://weapons/scattergun.tscn")

var _dummy: TargetDummy
var _gun: ScatterGun
var _ticks: int = 0


func _ready() -> void:
	_dummy = DUMMY_SCENE.instantiate()
	_dummy.position = Vector3(0, 0, -4)
	add_child(_dummy)
	_gun = GUN_SCENE.instantiate()
	_gun.position = Vector3(0, 1, 0)
	add_child(_gun)


func _physics_process(_delta: float) -> void:
	_ticks += 1
	if _ticks == 5:
		_gun.try_fire()
	if _ticks < 60:
		return
	var hp: int = _dummy.get_node("HealthComponent").current_health
	print("dummy HP %d (want < 50 after one blast), ammo %d/40" % [hp, _gun.ammo])
	if hp < 50 and _gun.ammo == 39:
		print("PASS: scattergun")
		get_tree().quit(0)
	else:
		print("FAIL: scattergun")
		get_tree().quit(1)
