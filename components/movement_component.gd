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

@export_group("Jump")
@export var jump_height: float = 4.5
@export var double_jump_height: float = 3.2
@export var air_jumps: int = 1
@export var coyote_time: float = 0.12
@export var jump_buffer_time: float = 0.15

@export_group("Gravity")
@export var gravity_multiplier: float = 1.8

var _base_gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
var _coyote_timer: float = 0.0
var _buffer_timer: float = 0.0
var _air_jumps_left: int = 0
var _jump_pressed_this_tick: bool = false


func _ready() -> void:
	input_component.jump_pressed.connect(_on_jump_pressed)


func _on_jump_pressed() -> void:
	_jump_pressed_this_tick = true
	_buffer_timer = jump_buffer_time


func _physics_process(delta: float) -> void:
	if body.is_on_floor():
		_coyote_timer = coyote_time
		_air_jumps_left = air_jumps
	else:
		body.velocity.y -= _base_gravity * gravity_multiplier * delta

	var can_ground_jump: bool = body.is_on_floor() or _coyote_timer > 0.0
	if _buffer_timer > 0.0 and can_ground_jump:
		_jump(jump_height)
	elif _jump_pressed_this_tick and not can_ground_jump and _air_jumps_left > 0:
		_air_jumps_left -= 1
		_jump(double_jump_height)
	_jump_pressed_this_tick = false
	_coyote_timer = maxf(_coyote_timer - delta, 0.0)
	_buffer_timer = maxf(_buffer_timer - delta, 0.0)

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


func _jump(height: float) -> void:
	body.velocity.y = sqrt(2.0 * _base_gravity * gravity_multiplier * height)
	_coyote_timer = 0.0
	_buffer_timer = 0.0


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
