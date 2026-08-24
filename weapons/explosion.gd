class_name Explosion
extends Area3D

## One-shot area damage: waits two physics frames so overlaps register,
## hits every enemy hurtbox in radius, plays a quick scale-up, then frees.

@export var damage: int = 30

@onready var _mesh: MeshInstance3D = $MeshInstance3D


func _ready() -> void:
	_detonate()


func _detonate() -> void:
	await get_tree().physics_frame
	await get_tree().physics_frame
	for area in get_overlapping_areas():
		var hurtbox: HurtboxComponent = area as HurtboxComponent
		if hurtbox != null:
			hurtbox.receive_hit(damage)
	_mesh.scale = Vector3.ONE * 0.2
	var tween: Tween = create_tween()
	tween.tween_property(_mesh, "scale", Vector3.ONE, 0.2)
	tween.tween_interval(0.15)
	tween.tween_callback(queue_free)
