class_name TorqueWrench
extends Weapon

## Melee swing: arcs the wrench mesh while a fixed frontal hitbox is live.
## Can also be thrown as a returning projectile; while it's out, the held
## wrench is gone and can't swing.

@export var swing_duration: float = 0.3
@export var projectile_scene: PackedScene

@onready var _pivot: Node3D = $SwingPivot
@onready var _hitbox: HitboxComponent = $HitboxComponent

var is_thrown: bool = false


func try_fire() -> bool:
	if is_thrown:
		return false
	return super.try_fire()


func try_throw(wielder: Node3D) -> bool:
	if is_thrown or projectile_scene == null:
		return false
	is_thrown = true
	visible = false
	var projectile: WrenchProjectile = projectile_scene.instantiate()
	projectile.setup(wielder, get_aim_direction())
	projectile.position = global_position
	projectile.returned.connect(_on_projectile_returned)
	get_tree().current_scene.add_child(projectile)
	return true


func _on_projectile_returned() -> void:
	is_thrown = false
	visible = is_equipped


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
