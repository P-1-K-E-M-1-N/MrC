class_name MovementComponent
extends Node

## Drives a CharacterBody3D from movement intents: gravity, ground run, jumps.

@export var body: CharacterBody3D
@export var input_component: InputComponent
@export var visual: Node3D

@export var gravity_multiplier: float = 1.8

var _base_gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")


func _physics_process(delta: float) -> void:
	if not body.is_on_floor():
		body.velocity.y -= _base_gravity * gravity_multiplier * delta
	body.move_and_slide()
