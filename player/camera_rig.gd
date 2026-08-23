class_name CameraRig
extends Node3D

## Third-person orbit camera. Yaw lives on this node, pitch on the spring arm,
## so movement code can grab a flat yaw basis for camera-relative input.
## top_level detaches it from the hero so the follow position can lag.

@export var anchor: Node3D
@export var mouse_sensitivity: float = 0.0025
@export var stick_speed: float = 2.5
@export var pitch_min_degrees: float = -60.0
@export var pitch_max_degrees: float = 75.0
@export var follow_speed: float = 14.0

@onready var _spring_arm: SpringArm3D = $SpringArm3D


func _ready() -> void:
	top_level = true
	global_position = anchor.global_position


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		var motion: InputEventMouseMotion = event
		rotation.y -= motion.relative.x * mouse_sensitivity
		_spring_arm.rotation.x -= motion.relative.y * mouse_sensitivity
		_clamp_pitch()


func _physics_process(delta: float) -> void:
	var stick: Vector2 = Input.get_vector("camera_left", "camera_right", "camera_up", "camera_down")
	rotation.y -= stick.x * stick_speed * delta
	_spring_arm.rotation.x -= stick.y * stick_speed * delta
	_clamp_pitch()
	# Framerate-independent exponential smoothing toward the anchor.
	var weight: float = 1.0 - exp(-follow_speed * delta)
	global_position = global_position.lerp(anchor.global_position, weight)


func get_yaw_basis() -> Basis:
	return Basis(Vector3.UP, rotation.y)


func _clamp_pitch() -> void:
	_spring_arm.rotation.x = clampf(
		_spring_arm.rotation.x,
		deg_to_rad(pitch_min_degrees),
		deg_to_rad(pitch_max_degrees)
	)
