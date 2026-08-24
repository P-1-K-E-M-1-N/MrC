@tool
extends BTCondition

## SUCCESS when the blackboard target is within [member range] (flat).

@export var target_var: StringName = &"player"
@export var range: float = 2.0


func _generate_name() -> String:
	return "TargetInRange %.1f m" % range


func _tick(_delta: float) -> Status:
	var enemy: EnemyBase = agent as EnemyBase
	var target: Node3D = blackboard.get_var(target_var, null)
	if enemy == null or not is_instance_valid(target):
		return FAILURE
	if enemy.flat_distance_to(target.global_position) <= range:
		return SUCCESS
	return FAILURE
