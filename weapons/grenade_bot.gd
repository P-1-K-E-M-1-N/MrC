class_name LobBot
extends Weapon

## Grenade launcher: lobs an arcing bomb along the aim line.

@export var grenade_scene: PackedScene

@onready var _muzzle: Marker3D = $Muzzle


func _fire() -> void:
	var grenade: Grenade = grenade_scene.instantiate()
	grenade.position = _muzzle.global_position
	get_tree().current_scene.add_child(grenade)
	grenade.launch(get_aim_direction())
