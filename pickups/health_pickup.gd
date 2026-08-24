class_name HealthPickup
extends Area3D

## Floating heal. Consumed on player touch unless they're at full HP.

@export var heal_amount: int = 25
@export var bob_height: float = 0.15
@export var spin_speed: float = 2.0

var _base_y: float
var _time: float = 0.0


func _ready() -> void:
	_base_y = position.y
	body_entered.connect(_on_body_entered)


func _process(delta: float) -> void:
	_time += delta
	position.y = _base_y + sin(_time * 2.5) * bob_height
	rotation.y += spin_speed * delta
	# A full-HP player can stand inside the pickup; consume the moment
	# they lose health rather than requiring re-entry.
	for body in get_overlapping_bodies():
		_try_consume(body)


func _on_body_entered(body: Node3D) -> void:
	_try_consume(body)


func _try_consume(body: Node3D) -> void:
	var health: HealthComponent = body.get_node_or_null("HealthComponent") as HealthComponent
	if health == null or health.current_health >= health.max_health:
		return
	health.heal(heal_amount)
	queue_free()
