class_name PauseMenu
extends CanvasLayer

## Esc or the controller Start button pauses the tree and shows
## Resume/Quit with the mouse freed. Runs with PROCESS_MODE_ALWAYS so it
## still hears input while paused; Resume grabs focus so d-pad + accept
## navigate without a mouse.


@onready var _resume_button: Button = $VBox/Resume
@onready var _quit_button: Button = $VBox/Quit


func _ready() -> void:
	visible = false
	_resume_button.pressed.connect(_resume)
	_quit_button.pressed.connect(func() -> void: get_tree().quit())


func _unhandled_input(event: InputEvent) -> void:
	if not event.is_action_pressed("pause"):
		return
	if get_tree().paused:
		_resume()
	else:
		_pause()


func _pause() -> void:
	get_tree().paused = true
	visible = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	_resume_button.grab_focus()


func _resume() -> void:
	get_tree().paused = false
	visible = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
