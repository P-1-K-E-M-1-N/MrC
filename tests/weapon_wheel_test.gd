extends Node

## Headless check: holding the wheel action slows time and shows the
## wheel; flicking right and releasing equips slot 1 and restores time.
## Run: godot --headless --path . res://tests/weapon_wheel_test.tscn

const HERO_SCENE: PackedScene = preload("res://player/hero.tscn")

var _hero: Hero
var _wheel: WeaponWheel
var _holder: WeaponHolderComponent
var _ticks: int = 0
var _failures: Array[String] = []


func _ready() -> void:
	_hero = HERO_SCENE.instantiate()
	_hero.position = Vector3(0, 0.1, 0)
	add_child(_hero)
	_wheel = _hero.get_node("WeaponWheel")
	_holder = _hero.get_node("WeaponHolderComponent")


func _physics_process(_delta: float) -> void:
	_ticks += 1
	match _ticks:
		10:
			_send_action(true)
		20:
			_check(_wheel.visible, "wheel visible while held")
			_check(is_equal_approx(Engine.time_scale, 0.25), "time slowed while held")
			var motion: InputEventMouseMotion = InputEventMouseMotion.new()
			motion.relative = Vector2(200, 0)
			Input.parse_input_event(motion)
		30:
			_send_action(false)
		40:
			_check(not _wheel.visible, "wheel hidden after release")
			_check(is_equal_approx(Engine.time_scale, 1.0), "time restored after release")
			_check(_holder.current_index == 1,
				"flick right equipped slot 1 (got %d)" % _holder.current_index)
			if _failures.is_empty():
				print("PASS: weapon wheel")
				get_tree().quit(0)
			else:
				print("FAIL: ", ", ".join(_failures))
				get_tree().quit(1)


func _send_action(pressed: bool) -> void:
	var event: InputEventAction = InputEventAction.new()
	event.action = "weapon_wheel"
	event.pressed = pressed
	Input.parse_input_event(event)


func _check(condition: bool, label: String) -> void:
	print(("ok: " if condition else "FAILED: ") + label)
	if not condition:
		_failures.append(label)
