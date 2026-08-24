@tool
extends BTAction

## One full melee attack: face the target through a windup, arm the
## enemy's melee hitbox for the strike window, then recover.

@export var target_var: StringName = &"player"
@export var windup: float = 0.35
@export var strike: float = 0.15
@export var recover: float = 0.4

var _time: float = 0.0
var _hitbox_active: bool = false


func _generate_name() -> String:
	return "MeleeStrike"


func _enter() -> void:
	_time = 0.0
	_hitbox_active = false


func _tick(delta: float) -> Status:
	var enemy: EnemyBase = agent as EnemyBase
	var target: Node3D = blackboard.get_var(target_var, null)
	if enemy == null or not is_instance_valid(target):
		return FAILURE
	var hitbox: HitboxComponent = enemy.get_node("MeleeHitbox")
	enemy.stop()
	_time += delta
	if _time < windup:
		enemy.face_point(target.global_position, delta)
	elif _time < windup + strike:
		if not _hitbox_active:
			hitbox.activate()
			_hitbox_active = true
	elif _time < windup + strike + recover:
		if _hitbox_active:
			hitbox.deactivate()
			_hitbox_active = false
	else:
		return SUCCESS
	return RUNNING


func _exit() -> void:
	if _hitbox_active:
		var enemy: EnemyBase = agent as EnemyBase
		if enemy != null:
			var hitbox: HitboxComponent = enemy.get_node("MeleeHitbox")
			hitbox.deactivate()
		_hitbox_active = false
