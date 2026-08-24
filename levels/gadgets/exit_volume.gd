class_name ExitVolume
extends Area3D

## End of the slice: stepping in shows the completion overlay.

@onready var _overlay: CanvasLayer = $Overlay


func _ready() -> void:
	_overlay.visible = false
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node3D) -> void:
	if body is Hero:
		_overlay.visible = true
