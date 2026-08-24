class_name HurtboxComponent
extends Area3D

## Damage receiver. Sits on layer "hurtbox"; hitboxes and projectiles
## find it via area overlap and call receive_hit.

signal hit_received(amount: int)

@export var health_component: HealthComponent
## Pop a floating damage number on every hit.
@export var show_damage_numbers: bool = true


func receive_hit(amount: int) -> void:
	hit_received.emit(amount)
	if show_damage_numbers:
		_spawn_damage_number(amount)
	if health_component != null:
		health_component.take_damage(amount)


func _spawn_damage_number(amount: int) -> void:
	var number: DamageNumber = DamageNumber.create(amount)
	number.position = global_position + Vector3(
		randf_range(-0.3, 0.3), 1.4, randf_range(-0.3, 0.3)
	)
	get_tree().current_scene.add_child(number)
