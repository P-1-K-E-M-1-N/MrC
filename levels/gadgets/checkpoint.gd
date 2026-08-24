class_name Checkpoint
extends Area3D

## Touching this moves the hero's respawn point here. The ring glows
## green once activated; activating one dims the others.

@onready var _ring: MeshInstance3D = $Ring

var _active_material: StandardMaterial3D
var _inactive_material: StandardMaterial3D


func _ready() -> void:
	add_to_group("checkpoints")
	body_entered.connect(_on_body_entered)
	_inactive_material = _ring.get_active_material(0)
	_active_material = _inactive_material.duplicate()
	_active_material.albedo_color = Color(0.2, 0.95, 0.35)
	_active_material.emission = Color(0.15, 0.85, 0.25)


func _on_body_entered(body: Node3D) -> void:
	var hero: Hero = body as Hero
	if hero == null:
		return
	hero.set_spawn(Transform3D(Basis.IDENTITY, global_position + Vector3(0, 0.2, 0)))
	for checkpoint in get_tree().get_nodes_in_group("checkpoints"):
		(checkpoint as Checkpoint).set_active(checkpoint == self)


func set_active(active: bool) -> void:
	_ring.material_override = _active_material if active else null
