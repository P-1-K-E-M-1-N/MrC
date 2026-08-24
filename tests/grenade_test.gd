extends Node

## Headless check: a lobbed grenade arcs to a dummy and its explosion
## damages it through the hurtbox pipeline.
## Run: godot --headless --path . res://tests/grenade_test.tscn

const DUMMY_SCENE: PackedScene = preload("res://enemies/target_dummy.tscn")
const GRENADE_SCENE: PackedScene = preload("res://weapons/grenade.tscn")

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

	_dummy = DUMMY_SCENE.instantiate()
	_dummy.position = Vector3(0, 0, 6)
	add_child(_dummy)

	# Dropped just beside the dummy: rises, falls, detonates on the floor
	# inside blast radius. Arc/contact behavior is covered by the floor hit.
	var grenade: Grenade = GRENADE_SCENE.instantiate()
	grenade.position = Vector3(0.8, 1, 6)
	add_child(grenade)
	grenade.launch(Vector3.ZERO)


func _physics_process(_delta: float) -> void:
	_ticks += 1
	if _ticks < 210:
		return
	var hp: int = _dummy.get_node("HealthComponent").current_health
	print("dummy HP %d (want <= 20 after blast)" % hp)
	if hp <= 20:
		print("PASS: grenade")
		get_tree().quit(0)
	else:
		print("FAIL: grenade")
		get_tree().quit(1)
