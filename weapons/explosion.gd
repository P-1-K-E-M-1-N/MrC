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
			hurtbox.receive_hit(damage, global_position)
	var player: Node3D = get_tree().get_first_node_in_group("player") as Node3D
	if player != null and player.global_position.distance_to(global_position) < 9.0:
		var rig: CameraRig = player.get_node_or_null("CameraRig")
		if rig != null:
			rig.add_trauma(0.4)
		Input.start_joy_vibration(0, 0.3, 0.6, 0.25)
	_mesh.scale = Vector3.ONE * 0.2
	var tween: Tween = create_tween()
	tween.tween_property(_mesh, "scale", Vector3.ONE, 0.2)
	tween.tween_interval(0.15)
	tween.tween_callback(queue_free)
