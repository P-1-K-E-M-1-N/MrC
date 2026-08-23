extends Node

## Headless combat check: a blaster bolt and a wrench swing must each
## damage a target dummy through the hurtbox pipeline.
## Run: godot --headless --path . res://tests/combat_test.tscn

const DUMMY_SCENE: PackedScene = preload("res://enemies/target_dummy.tscn")
const BOLT_SCENE: PackedScene = preload("res://weapons/blaster_bolt.tscn")
const WRENCH_SCENE: PackedScene = preload("res://weapons/wrench.tscn")

var _bolt_dummy: TargetDummy
var _wrench_dummy: TargetDummy
var _wrench: TorqueWrench
var _ticks: int = 0


func _ready() -> void:
	_bolt_dummy = DUMMY_SCENE.instantiate()
	add_child(_bolt_dummy)
	_bolt_dummy.global_position = Vector3.ZERO

	var bolt: BlasterBolt = BOLT_SCENE.instantiate()
	add_child(bolt)
	bolt.global_position = Vector3(0, 0.9, 5)

	_wrench_dummy = DUMMY_SCENE.instantiate()
	add_child(_wrench_dummy)
	_wrench_dummy.global_position = Vector3(5, 0, 0)

	_wrench = WRENCH_SCENE.instantiate()
	add_child(_wrench)
	_wrench.global_position = Vector3(5.45, 0.9, 0.6)


func _physics_process(_delta: float) -> void:
	_ticks += 1
	if _ticks == 90:
		_wrench.try_fire()
	if _ticks < 150:
		return
	var bolt_hp: int = _bolt_dummy.get_node("HealthComponent").current_health
	var wrench_hp: int = _wrench_dummy.get_node("HealthComponent").current_health
	var bolt_ok: bool = bolt_hp == 40
	var wrench_ok: bool = wrench_hp == 25
	print("bolt dummy HP %d (want 40), wrench dummy HP %d (want 25)" % [bolt_hp, wrench_hp])
	if bolt_ok and wrench_ok:
		print("PASS: combat pipeline")
		get_tree().quit(0)
	else:
		print("FAIL: combat pipeline")
		get_tree().quit(1)
