class_name ShooterEnemy
extends EnemyBase

## Ranged enemy: fires bolts from its muzzle; movement decisions live in
## its behavior tree (keep distance, shoot, approach).

@export var bolt_scene: PackedScene

@onready var _muzzle: Marker3D = $Muzzle


func fire_bolt(target_point: Vector3) -> void:
	var bolt: BlasterBolt = bolt_scene.instantiate()
	var direction: Vector3 = (target_point - _muzzle.global_position).normalized()
	bolt.transform = Transform3D(Basis.looking_at(direction), _muzzle.global_position)
	get_tree().current_scene.add_child(bolt)
