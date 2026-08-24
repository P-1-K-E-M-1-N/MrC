@tool
extends BTAction

## Back away from the blackboard target. RUNNING while too close,
## SUCCESS once at least [member safe_distance] away.

@export var target_var: StringName = &"player"
@export var safe_distance: float = 6.0


func _generate_name() -> String:
	return "FleeTarget (to %.1f m)" % safe_distance


func _tick(_delta: float) -> Status:
	var enemy: EnemyBase = agent as EnemyBase
	var target: Node3D = blackboard.get_var(target_var, null)
	if enemy == null or not is_instance_valid(target):
		return FAILURE
	if enemy.flat_distance_to(target.global_position) >= safe_distance:
		enemy.stop()
		return SUCCESS
	enemy.steer(-enemy.flat_direction_to(target.global_position), enemy.move_speed)
	return RUNNING
