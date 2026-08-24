class_name HealthComponent
extends Node

## HP pool with damage intake, optional post-hit invulnerability window,
## and death signal.

signal health_changed(current: int, max_value: int)
signal died

@export var max_health: int = 100
## Seconds of invulnerability after taking a hit. 0 disables.
@export var invuln_time: float = 0.0

var current_health: int

var _invuln_until_msec: int = 0


func _ready() -> void:
	current_health = max_health


func take_damage(amount: int) -> void:
	if is_invulnerable():
		return
	if invuln_time > 0.0:
		_invuln_until_msec = Time.get_ticks_msec() + int(invuln_time * 1000.0)
	current_health = maxi(current_health - amount, 0)
	health_changed.emit(current_health, max_health)
	if current_health == 0:
		died.emit()


func is_invulnerable() -> bool:
	return Time.get_ticks_msec() < _invuln_until_msec


func reset() -> void:
	current_health = max_health
	_invuln_until_msec = 0
	health_changed.emit(current_health, max_health)


func heal(amount: int) -> void:
	current_health = mini(current_health + amount, max_health)
	health_changed.emit(current_health, max_health)
