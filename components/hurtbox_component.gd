class_name HurtboxComponent
extends Area3D

## Damage receiver. Sits on layer "hurtbox"; hitboxes and projectiles
## find it via area overlap and call receive_hit.

signal hit_received(amount: int)

@export var health_component: HealthComponent
## Pop a floating damage number on every hit.
@export var show_damage_numbers: bool = true
## Shove applied away from the hit source (character bodies only).
@export var knockback_force: float = 6.0


func receive_hit(amount: int, from_position: Vector3 = Vector3.INF) -> void:
	hit_received.emit(amount)
	if show_damage_numbers:
		_spawn_damage_number(amount)
	if from_position.is_finite():
		_apply_knockback(from_position)
	if health_component != null:
		health_component.take_damage(amount)


func _apply_knockback(from_position: Vector3) -> void:
	var body: CharacterBody3D = get_parent() as CharacterBody3D
	if body == null:
		return
	var direction: Vector3 = body.global_position - from_position
	direction.y = 0.0
	if direction.length_squared() < 0.001:
		return
	var impulse: Vector3 = direction.normalized() * knockback_force + Vector3.UP * 1.2
	if body.has_method("apply_knockback"):
		body.apply_knockback(impulse)
	else:
		body.velocity += impulse * 0.6


func _spawn_damage_number(amount: int) -> void:
	var number: DamageNumber = DamageNumber.create(amount)
	number.position = global_position + Vector3(
		randf_range(-0.3, 0.3), 1.4, randf_range(-0.3, 0.3)
	)
	get_tree().current_scene.add_child(number)
