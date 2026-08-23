class_name Weapon
extends Node3D

## Base for all hero weapons. Subclasses override _fire(); the base owns
## ammo, fire cadence, and equip visibility.

signal ammo_changed(current: int, max_value: int)

@export var display_name: String = "Weapon"
## -1 means infinite ammo (melee).
@export var max_ammo: int = -1
@export var fire_interval: float = 0.5
## Seconds the wielder is committed after firing — no other attacks
## until it elapses. 0 for weapons that don't lock (guns).
@export var attack_lock: float = 0.0

var ammo: int
var is_equipped: bool = false
var _cooldown: float = 0.0


func _ready() -> void:
	ammo = max_ammo


func _process(delta: float) -> void:
	_cooldown = maxf(_cooldown - delta, 0.0)


func try_fire() -> bool:
	if _cooldown > 0.0:
		return false
	if max_ammo >= 0 and ammo <= 0:
		return false
	_cooldown = fire_interval
	if max_ammo >= 0:
		ammo -= 1
		ammo_changed.emit(ammo, max_ammo)
	_fire()
	return true


func on_equipped() -> void:
	is_equipped = true
	visible = true


func on_unequipped() -> void:
	is_equipped = false
	visible = false


## Aim direction along the wielder's facing, flat on the ground plane.
func get_aim_direction() -> Vector3:
	var forward: Vector3 = -global_transform.basis.z
	forward.y = 0.0
	return forward.normalized()


func _fire() -> void:
	pass
