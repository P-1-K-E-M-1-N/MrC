class_name BoltPickup
extends Area3D

## One unit of currency. Sits and spins; magnetizes to the player once
## they come near, then banks itself into their WalletComponent on touch.

@export var value: int = 1
@export var magnet_range: float = 4.5
@export var magnet_acceleration: float = 30.0
@export var spin_speed: float = 4.0

var _speed: float = 0.0


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _physics_process(delta: float) -> void:
	rotation.y += spin_speed * delta
	var player: Node3D = get_tree().get_first_node_in_group("player") as Node3D
	if player == null:
		return
	var target: Vector3 = player.global_position + Vector3(0, 0.9, 0)
	if global_position.distance_to(target) > magnet_range:
		_speed = 0.0
		return
	_speed += magnet_acceleration * delta
	global_position = global_position.move_toward(target, _speed * delta)


func _on_body_entered(body: Node3D) -> void:
	var wallet: WalletComponent = body.get_node_or_null("WalletComponent") as WalletComponent
	if wallet == null:
		return
	wallet.add(value)
	queue_free()
