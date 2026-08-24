class_name ScatterGun
extends Weapon

## Close-range spread gun: one trigger pull sprays a cone of short-lived
## pellets. Devastating point-blank, harmless past ~12 m.

@export var pellet_scene: PackedScene
@export var pellet_count: int = 6
@export var spread_degrees: float = 9.0

@onready var _muzzle: Marker3D = $Muzzle


func _fire() -> void:
	var aim: Vector3 = get_aim_direction_from(_muzzle.global_position)
	var right: Vector3 = aim.cross(Vector3.UP).normalized()
	for i in pellet_count:
		var direction: Vector3 = aim.rotated(
			Vector3.UP, randf_range(-1.0, 1.0) * deg_to_rad(spread_degrees)
		)
		direction = direction.rotated(
			right, randf_range(-1.0, 1.0) * deg_to_rad(spread_degrees * 0.5)
		).normalized()
		var pellet: BlasterBolt = pellet_scene.instantiate()
		pellet.transform = Transform3D(Basis.looking_at(direction), _muzzle.global_position)
		get_tree().current_scene.add_child(pellet)
