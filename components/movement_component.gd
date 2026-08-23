class_name MovementComponent
extends Node

## Drives a CharacterBody3D from movement intents: gravity, ground run, jumps.

@export var body: CharacterBody3D
@export var input_component: InputComponent
@export var camera_rig: CameraRig
@export var visual: Node3D

@export_group("Run")
@export var max_speed: float = 7.0
@export var acceleration: float = 40.0
@export var deceleration: float = 60.0
@export var turn_speed: float = 12.0

@export_group("Gravity")
@export var gravity_multiplier: float = 1.8

var _base_gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")


func _physics_process(delta: float) -> void:
	if not body.is_on_floor():
		body.velocity.y -= _base_gravity * gravity_multiplier * delta

	var move_direction: Vector3 = _get_world_move_direction()
	var horizontal: Vector3 = Vector3(body.velocity.x, 0.0, body.velocity.z)
	if move_direction != Vector3.ZERO:
		horizontal = horizontal.move_toward(move_direction * max_speed, acceleration * delta)
	else:
		horizontal = horizontal.move_toward(Vector3.ZERO, deceleration * delta)
	body.velocity.x = horizontal.x
	body.velocity.z = horizontal.z

	body.move_and_slide()
	_face_move_direction(move_direction, delta)


func _get_world_move_direction() -> Vector3:
	var input_vector: Vector2 = input_component.move_vector
	var direction: Vector3 = Vector3(input_vector.x, 0.0, input_vector.y)
	if camera_rig != null:
		direction = camera_rig.get_yaw_basis() * direction
	return direction.limit_length(1.0)


func _face_move_direction(move_direction: Vector3, delta: float) -> void:
	if move_direction.length_squared() < 0.001:
		return
	var target_yaw: float = atan2(-move_direction.x, -move_direction.z)
	var weight: float = 1.0 - exp(-turn_speed * delta)
	visual.rotation.y = lerp_angle(visual.rotation.y, target_yaw, weight)
