@tool
extends BTAction

## Run toward the blackboard target. RUNNING while closing distance,
## SUCCESS once within [member stop_distance].

@export var target_var: StringName = &"player"
@export var stop_distance: float = 1.5
## Targets beyond this are ignored — the enemy idles instead of
## beelining across the whole map.
@export var aggro_range: float = 22.0


func _generate_name() -> String:
	return "ChaseTarget (stop at %.1f m, aggro %.0f m)" % [stop_distance, aggro_range]


func _tick(_delta: float) -> Status:
	var enemy: EnemyBase = agent as EnemyBase
	var target: Node3D = blackboard.get_var(target_var, null)
	if enemy == null or not is_instance_valid(target):
		return FAILURE
	var distance: float = enemy.flat_distance_to(target.global_position)
	if distance > aggro_range:
		enemy.stop()
		return FAILURE
	if distance <= stop_distance:
		enemy.stop()
		return SUCCESS
	enemy.steer(enemy.flat_direction_to(target.global_position), enemy.move_speed)
	return RUNNING
