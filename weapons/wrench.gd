class_name TorqueWrench
extends Weapon

## Melee swing: arcs the wrench mesh while a fixed frontal hitbox is live.

@export var swing_duration: float = 0.3

@onready var _pivot: Node3D = $SwingPivot
@onready var _hitbox: HitboxComponent = $HitboxComponent


func _fire() -> void:
	visible = true
	_hitbox.activate()
	_pivot.rotation.y = deg_to_rad(70.0)
	var tween: Tween = create_tween()
	tween.tween_property(_pivot, "rotation:y", deg_to_rad(-70.0), swing_duration)
	tween.tween_callback(_end_swing)


func _end_swing() -> void:
	_hitbox.deactivate()
	_pivot.rotation.y = 0.0
	visible = is_equipped
