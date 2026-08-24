class_name JumpPad
extends Area3D

## Launches any character that steps on it straight up.

@export var launch_velocity: float = 18.0

@onready var _disc: MeshInstance3D = $Disc


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node3D) -> void:
	var character: CharacterBody3D = body as CharacterBody3D
	if character == null:
		return
	character.velocity.y = launch_velocity
	_disc.scale = Vector3(1.3, 0.6, 1.3)
	var tween: Tween = create_tween()
	tween.tween_property(_disc, "scale", Vector3.ONE, 0.25)
