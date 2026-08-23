class_name CameraRig
extends Node3D

## Third-person orbit camera. Yaw lives on this node, pitch on the spring arm,
## so movement code can grab a flat yaw basis for camera-relative input.
## top_level detaches it from the hero so the follow position can lag.

@export var anchor: Node3D
## Node whose yaw the camera recenters behind (the hero's rotating visual).
@export var facing_target: Node3D
@export var mouse_sensitivity: float = 0.0025
@export var stick_speed: float = 2.5
@export var pitch_min_degrees: float = -60.0
@export var pitch_max_degrees: float = 75.0
@export var follow_speed: float = 14.0

@export_group("Auto recenter")
@export var auto_recenter: bool = true
## Seconds without manual camera input before recentering kicks in.
@export var recenter_delay: float = 0.9
@export var recenter_speed: float = 3.0
## How hard the yaw tracks a lock-on target.
@export var lock_track_speed: float = 8.0

@onready var _spring_arm: SpringArm3D = $SpringArm3D

## Set by LockOnComponent; while valid, yaw is driven at the target.
var lock_target: Node3D = null

var _recenter_timer: float = 0.0


func _ready() -> void:
	top_level = true
	global_position = anchor.global_position


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		var motion: InputEventMouseMotion = event
		if not _is_locked():
			rotation.y -= motion.relative.x * mouse_sensitivity
		_spring_arm.rotation.x -= motion.relative.y * mouse_sensitivity
		_clamp_pitch()
		_recenter_timer = recenter_delay


func _physics_process(delta: float) -> void:
	var stick: Vector2 = Input.get_vector("camera_left", "camera_right", "camera_up", "camera_down")
	if stick != Vector2.ZERO:
		if not _is_locked():
			rotation.y -= stick.x * stick_speed * delta
		_spring_arm.rotation.x -= stick.y * stick_speed * delta
		_clamp_pitch()
		_recenter_timer = recenter_delay

	_recenter_timer = maxf(_recenter_timer - delta, 0.0)
	if _is_locked():
		var to_target: Vector3 = lock_target.global_position - anchor.global_position
		var desired_yaw: float = atan2(-to_target.x, -to_target.z)
		var track_weight: float = 1.0 - exp(-lock_track_speed * delta)
		rotation.y = lerp_angle(rotation.y, desired_yaw, track_weight)
	elif auto_recenter and _recenter_timer <= 0.0 and facing_target != null:
		var recenter_weight: float = 1.0 - exp(-recenter_speed * delta)
		rotation.y = lerp_angle(rotation.y, facing_target.global_rotation.y, recenter_weight)

	# Framerate-independent exponential smoothing toward the anchor.
	var weight: float = 1.0 - exp(-follow_speed * delta)
	global_position = global_position.lerp(anchor.global_position, weight)


func _is_locked() -> bool:
	return lock_target != null and is_instance_valid(lock_target)


func get_yaw_basis() -> Basis:
	return Basis(Vector3.UP, rotation.y)


func _clamp_pitch() -> void:
	_spring_arm.rotation.x = clampf(
		_spring_arm.rotation.x,
		deg_to_rad(pitch_min_degrees),
		deg_to_rad(pitch_max_degrees)
	)
