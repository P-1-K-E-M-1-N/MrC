class_name PauseMenu
extends CanvasLayer

## Esc pauses the tree and shows Resume/Quit with the mouse freed.
## Runs with PROCESS_MODE_ALWAYS so it still hears input while paused.


@onready var _resume_button: Button = $VBox/Resume
@onready var _quit_button: Button = $VBox/Quit


func _ready() -> void:
	visible = false
	_resume_button.pressed.connect(_resume)
	_quit_button.pressed.connect(func() -> void: get_tree().quit())


func _unhandled_input(event: InputEvent) -> void:
	if not event.is_action_pressed("ui_cancel"):
		return
	if get_tree().paused:
		_resume()
	else:
		_pause()


func _pause() -> void:
	get_tree().paused = true
	visible = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func _resume() -> void:
	get_tree().paused = false
	visible = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
