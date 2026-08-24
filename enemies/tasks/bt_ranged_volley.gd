@tool
extends BTAction

## One ranged shot: face the target through a windup, fire the agent's
## bolt at it, then hold through a cooldown. Agent must be a ShooterEnemy.

@export var target_var: StringName = &"player"
@export var windup: float = 0.4
@export var cooldown: float = 1.2

var _time: float = 0.0
var _fired: bool = false


func _generate_name() -> String:
	return "RangedVolley"


func _enter() -> void:
	_time = 0.0
	_fired = false


func _tick(delta: float) -> Status:
	var shooter: ShooterEnemy = agent as ShooterEnemy
	var target: Node3D = blackboard.get_var(target_var, null)
	if shooter == null or not is_instance_valid(target):
		return FAILURE
	shooter.stop()
	_time += delta
	if _time < windup:
		shooter.face_point(target.global_position, delta)
	elif not _fired:
		shooter.fire_bolt(target.global_position + Vector3(0, 1, 0))
		_fired = true
	elif _time >= windup + cooldown:
		return SUCCESS
	return RUNNING
