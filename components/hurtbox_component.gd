class_name HurtboxComponent
extends Area3D

## Damage receiver. Sits on layer "hurtbox"; hitboxes and projectiles
## find it via area overlap and call receive_hit.

signal hit_received(amount: int)

@export var health_component: HealthComponent


func receive_hit(amount: int) -> void:
	hit_received.emit(amount)
	if health_component != null:
		health_component.take_damage(amount)
