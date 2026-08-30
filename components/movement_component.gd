class_name MovementComponent
extends Node

## Drives a CharacterBody3D from movement intents: gravity, ground run, jumps.

## Emitted when the air jump becomes a directional flip (direction held).
signal air_flipped(world_direction: Vector3)

@export var body: CharacterBody3D
@export var input_component: InputComponent
@export var camera_rig: CameraRig
@export var visual: Node3D
## While locked on, the body faces the target (strafe/backpedal mode).
@export var lock_on: LockOnComponent

@export_group("Run")
@export var max_speed: float = 7.0
@export var acceleration: float = 40.0
@export var deceleration: float = 60.0
@export var turn_speed: float = 12.0

@export_group("Jump")
@export var jump_height: float = 2.25
@export var double_jump_height: float = 1.6
@export var air_jumps: int = 1
@export var coyote_time: float = 0.12
@export var jump_buffer_time: float = 0.15
## Minimum time after a jump before the air jump may fire.
@export var double_jump_delay: float = 0.18
## Horizontal burst speed when the air jump is a directional flip.
@export var flip_speed: float = 10.0
## How long the flip burst outruns the normal speed cap.
@export var flip_duration: float = 0.45

@export_group("Gravity")
@export var gravity_multiplier: float = 2.0
## Extra gravity while falling, for a heavier arc without changing apex height.
@export var fall_gravity_multiplier: float = 1.3

var _base_gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
var _coyote_timer: float = 0.0
var _buffer_timer: float = 0.0
var _jump_lockout: float = 0.0
var _flip_timer: float = 0.0
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
		_flip_timer = 0.0
	else:
		var gravity: float = _base_gravity * gravity_multiplier
		if body.velocity.y < 0.0:
			gravity *= fall_gravity_multiplier
		body.velocity.y -= gravity * delta

	var can_ground_jump: bool = body.is_on_floor() or _coyote_timer > 0.0
	if _buffer_timer > 0.0 and can_ground_jump:
		_jump(jump_height)
	elif _jump_pressed_this_tick and not can_ground_jump \
			and _air_jumps_left > 0 and _jump_lockout <= 0.0:
		_air_jumps_left -= 1
		var flip_direction: Vector3 = _get_world_move_direction()
		if flip_direction.length_squared() > 0.04:
			flip_direction = flip_direction.normalized()
			body.velocity.x = flip_direction.x * flip_speed
			body.velocity.z = flip_direction.z * flip_speed
			_flip_timer = flip_duration
			air_flipped.emit(flip_direction)
		_jump(double_jump_height)
	_jump_pressed_this_tick = false
	_coyote_timer = maxf(_coyote_timer - delta, 0.0)
	_buffer_timer = maxf(_buffer_timer - delta, 0.0)
	_jump_lockout = maxf(_jump_lockout - delta, 0.0)
	_flip_timer = maxf(_flip_timer - delta, 0.0)

	var move_direction: Vector3 = _get_world_move_direction()
	var horizontal: Vector3 = Vector3(body.velocity.x, 0.0, body.velocity.z)
	if move_direction != Vector3.ZERO:
		var speed_cap: float = flip_speed if _flip_timer > 0.0 else max_speed
		horizontal = horizontal.move_toward(move_direction * speed_cap, acceleration * delta)
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
	_jump_lockout = double_jump_delay


func _get_world_move_direction() -> Vector3:
	var input_vector: Vector2 = input_component.move_vector
	var direction: Vector3 = Vector3(input_vector.x, 0.0, input_vector.y)
	if camera_rig != null:
		direction = camera_rig.get_yaw_basis() * direction
	return direction.limit_length(1.0)


func _face_move_direction(move_direction: Vector3, delta: float) -> void:
	var target_yaw: float
	if lock_on != null and lock_on.is_locked():
		var to_target: Vector3 = lock_on.target.global_position - body.global_position
		to_target.y = 0.0
		if to_target.length_squared() < 0.001:
			return
		target_yaw = atan2(-to_target.x, -to_target.z)
	elif move_direction.length_squared() >= 0.001:
		target_yaw = atan2(-move_direction.x, -move_direction.z)
	else:
		return
	var weight: float = 1.0 - exp(-turn_speed * delta)
	visual.rotation.y = lerp_angle(visual.rotation.y, target_yaw, weight)
