class_name InputComponent
extends Node

## Polls raw player input and exposes it as intents.
## Enemies get intents from AI instead — same consumers, different driver.

signal jump_pressed
signal jump_released
signal melee_pressed
signal melee_throw_pressed
signal weapon_next_pressed
signal weapon_prev_pressed
signal lock_on_pressed
signal interact_pressed
signal weapon_selected(index: int)

var move_vector: Vector2 = Vector2.ZERO
var attack_held: bool = false


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _process(_delta: float) -> void:
	move_vector = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	attack_held = Input.is_action_pressed("attack")


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("jump"):
		jump_pressed.emit()
	elif event.is_action_released("jump"):
		jump_released.emit()
	elif event.is_action_pressed("melee"):
		melee_pressed.emit()
	elif event.is_action_pressed("melee_throw"):
		melee_throw_pressed.emit()
	elif event.is_action_pressed("weapon_next"):
		weapon_next_pressed.emit()
	elif event.is_action_pressed("weapon_prev"):
		weapon_prev_pressed.emit()
	elif event.is_action_pressed("lock_on"):
		lock_on_pressed.emit()
	elif event.is_action_pressed("interact"):
		interact_pressed.emit()
	elif event.is_action_pressed("weapon_1"):
		weapon_selected.emit(0)
	elif event.is_action_pressed("weapon_2"):
		weapon_selected.emit(1)
	elif event.is_action_pressed("weapon_3"):
		weapon_selected.emit(2)
	elif event.is_action_pressed("weapon_4"):
		weapon_selected.emit(3)
