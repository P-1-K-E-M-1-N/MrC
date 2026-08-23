class_name BlasterBolt
extends Area3D

## Straight-line projectile. Damages the first hurtbox it overlaps,
## dies on world geometry or after lifetime expires.

@export var speed: float = 30.0
@export var damage: int = 10
@export var lifetime: float = 3.0


func _ready() -> void:
	area_entered.connect(_on_area_entered)
	body_entered.connect(_on_body_entered)
	get_tree().create_timer(lifetime).timeout.connect(queue_free)


func _physics_process(delta: float) -> void:
	global_position += -global_transform.basis.z * speed * delta


func _on_area_entered(area: Area3D) -> void:
	var hurtbox: HurtboxComponent = area as HurtboxComponent
	if hurtbox == null:
		return
	hurtbox.receive_hit(damage)
	queue_free()


func _on_body_entered(_body: Node3D) -> void:
	queue_free()
