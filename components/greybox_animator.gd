class_name GreyboxAnimator
extends Node

## Procedural greybox animation: swings limb pivots and bobs the rig in
## proportion to horizontal speed, and blends into a fixed jump pose while
## airborne. No AnimationPlayer — pure code, tunable via exports.

@export var body: CharacterBody3D
@export var rig: Node3D
@export var left_arm: Node3D
@export var right_arm: Node3D
@export var left_leg: Node3D
@export var right_leg: Node3D

@export var top_speed: float = 7.0
@export var swing_degrees: float = 45.0
@export var steps_per_second: float = 3.2
@export var bob_height: float = 0.06

var _phase: float = 0.0
var _rig_base_y: float = 0.0
var _air_blend: float = 0.0


func _ready() -> void:
	_rig_base_y = rig.position.y


func _process(delta: float) -> void:
	var flat_speed: float = Vector2(body.velocity.x, body.velocity.z).length()
	var run_t: float = clampf(flat_speed / top_speed, 0.0, 1.0)
	var grounded: bool = body.is_on_floor()
	_air_blend = move_toward(_air_blend, 0.0 if grounded else 1.0, delta * 6.0)
	if run_t > 0.02 and grounded:
		_phase += delta * steps_per_second * TAU
	var ground_blend: float = 1.0 - _air_blend
	var swing: float = sin(_phase) * deg_to_rad(swing_degrees) * run_t * ground_blend
	var arm_air: float = deg_to_rad(-55.0) * _air_blend
	var front_leg_air: float = deg_to_rad(30.0) * _air_blend
	var back_leg_air: float = deg_to_rad(-20.0) * _air_blend
	left_arm.rotation.x = swing + arm_air
	right_arm.rotation.x = -swing + arm_air
	left_leg.rotation.x = -swing + front_leg_air
	right_leg.rotation.x = swing + back_leg_air
	rig.position.y = _rig_base_y + absf(sin(_phase)) * bob_height * run_t * ground_blend
