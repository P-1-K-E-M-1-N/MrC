class_name PipBlaster
extends Weapon

## Rapid-fire gun: spawns a bolt from the muzzle along the wielder's facing.

@export var bolt_scene: PackedScene

@onready var _muzzle: Marker3D = $Muzzle


func _fire() -> void:
	var bolt: BlasterBolt = bolt_scene.instantiate()
	var direction: Vector3 = get_aim_direction_from(_muzzle.global_position)
	bolt.transform = Transform3D(Basis.looking_at(direction), _muzzle.global_position)
	get_tree().current_scene.add_child(bolt)
