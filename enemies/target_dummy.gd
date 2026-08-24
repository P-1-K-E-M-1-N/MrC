class_name TargetDummy
extends StaticBody3D

## Greybox punching bag: flashes a scale punch on hit, disappears at 0 HP.

## Where player weapons aim on this dummy.
@export var aim_height: float = 0.95

@onready var _health: HealthComponent = $HealthComponent
@onready var _hurtbox: HurtboxComponent = $HurtboxComponent
@onready var _mesh: MeshInstance3D = $MeshInstance3D


func _ready() -> void:
	add_to_group("enemies")
	_health.died.connect(queue_free)
	_hurtbox.hit_received.connect(_on_hit)


func _on_hit(_amount: int) -> void:
	_mesh.scale = Vector3(1.2, 0.85, 1.2)
	var tween: Tween = create_tween()
	tween.tween_property(_mesh, "scale", Vector3.ONE, 0.15)
