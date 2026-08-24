class_name WeaponHolderComponent
extends Node

## Owns the hero's weapons: instancing into the hand socket, cycling,
## and routing fire/melee intents. The melee weapon is always reachable
## via the melee button even when a gun is equipped.

signal weapon_changed(weapon: Weapon)

@export var socket: Node3D
@export var input_component: InputComponent
@export var camera_rig: CameraRig
@export var visual: Node3D
@export var weapon_scenes: Array[PackedScene] = []
## Index into weapon_scenes of the always-available melee weapon.
@export var melee_index: int = 0

var weapons: Array[Weapon] = []
var current_index: int = 0
var _attack_lock: float = 0.0


func _ready() -> void:
	for scene in weapon_scenes:
		var weapon: Weapon = scene.instantiate()
		socket.add_child(weapon)
		weapon.on_unequipped()
		weapons.append(weapon)
	if not weapons.is_empty():
		weapons[current_index].on_equipped()
		weapon_changed.emit(weapons[current_index])
	input_component.melee_pressed.connect(_on_melee_pressed)
	input_component.melee_throw_pressed.connect(_on_melee_throw_pressed)
	input_component.weapon_next_pressed.connect(func() -> void: _cycle(1))
	input_component.weapon_prev_pressed.connect(func() -> void: _cycle(-1))


func _process(delta: float) -> void:
	_attack_lock = maxf(_attack_lock - delta, 0.0)
	if input_component.attack_held and not weapons.is_empty():
		_attack_with(weapons[current_index])


func current_weapon() -> Weapon:
	return weapons[current_index] if not weapons.is_empty() else null


func _on_melee_pressed() -> void:
	if weapons.is_empty():
		return
	_attack_with(weapons[melee_index])


func _on_melee_throw_pressed() -> void:
	if weapons.is_empty() or _attack_lock > 0.0:
		return
	var wrench: TorqueWrench = weapons[melee_index] as TorqueWrench
	if wrench == null:
		return
	_face_camera_forward()
	if wrench.try_throw(visual):
		_attack_lock = 0.2


func _attack_with(weapon: Weapon) -> void:
	if _attack_lock > 0.0:
		return
	_face_camera_forward()
	if weapon.try_fire():
		_attack_lock = weapon.attack_lock


## Attacks commit the hero to the camera's forward direction so aiming
## follows the reticle line, not the last run direction.
func _face_camera_forward() -> void:
	if camera_rig != null and visual != null:
		visual.global_rotation.y = camera_rig.global_rotation.y


func _cycle(step: int) -> void:
	if weapons.size() < 2 or _attack_lock > 0.0:
		return
	weapons[current_index].on_unequipped()
	current_index = wrapi(current_index + step, 0, weapons.size())
	weapons[current_index].on_equipped()
	weapon_changed.emit(weapons[current_index])
