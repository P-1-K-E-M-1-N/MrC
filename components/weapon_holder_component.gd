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
@export var lock_on: LockOnComponent
@export var weapon_scenes: Array[PackedScene] = []
## Index into weapon_scenes of the always-available melee weapon.
@export var melee_index: int = 0

@export_group("Aim assist")
@export var aim_assist_range: float = 15.0
@export var aim_assist_angle_degrees: float = 75.0
## How fast the character turns onto an aim target (no instant snaps).
@export var aim_turn_speed: float = 16.0
## Seconds aim facing keeps overriding run facing after an attack.
@export var aim_hold_time: float = 0.4

var weapons: Array[Weapon] = []
var current_index: int = 0
var _attack_lock: float = 0.0
var _aim_point: Vector3 = Vector3.INF
var _aim_yaw: float = 0.0
var _aim_hold: float = 0.0


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
	input_component.weapon_selected.connect(_on_weapon_selected)


func _process(delta: float) -> void:
	_attack_lock = maxf(_attack_lock - delta, 0.0)
	if input_component.attack_held and not weapons.is_empty():
		_attack_with(weapons[current_index])
	# Smooth turn onto the aim yaw; runs after MovementComponent so aim
	# facing wins over run facing while an attack is fresh.
	if _aim_hold > 0.0:
		_aim_hold -= delta
		var turn_weight: float = 1.0 - exp(-aim_turn_speed * delta)
		visual.global_rotation.y = lerp_angle(visual.global_rotation.y, _aim_yaw, turn_weight)


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
	if camera_rig != null:
		camera_rig.notify_combat()
	_aim_before_attack()
	wrench.aim_point = _aim_point
	if wrench.try_throw(visual):
		_attack_lock = 0.2


func _attack_with(weapon: Weapon) -> void:
	if _attack_lock > 0.0:
		return
	if camera_rig != null:
		camera_rig.notify_combat()
	_aim_before_attack()
	weapon.aim_point = _aim_point
	if weapon.try_fire():
		_attack_lock = weapon.attack_lock
		Input.start_joy_vibration(0, 0.15, 0.0, 0.08)


## Aim priority: lock-on target, then the nearest enemy roughly in front
## (soft auto-aim), then camera forward when standing still. While moving
## with no target, the run facing is kept — the camera never has to be
## aimed precisely to fight.
func _aim_before_attack() -> void:
	_aim_point = Vector3.INF
	if lock_on != null and lock_on.is_locked():
		_aim_point = _target_aim_point(lock_on.target)
		_face_point(lock_on.target.global_position)
		return
	var soft_target: Node3D = _find_soft_target()
	if soft_target != null:
		_aim_point = _target_aim_point(soft_target)
		_face_point(soft_target.global_position)
	elif input_component.move_vector == Vector2.ZERO:
		_face_camera_forward()
		# Shots go down the camera line even while the body is mid-turn.
		var forward: Vector3 = -camera_rig.global_transform.basis.z
		forward.y = 0.0
		_aim_point = visual.global_position + forward.normalized() * 20.0 + Vector3.UP


## Chest height of a target: enemies declare aim_height; anything that
## doesn't gets a humanoid default.
func _target_aim_point(target: Node3D) -> Vector3:
	var height: Variant = target.get("aim_height")
	var offset: float = height if height is float else 0.9
	return target.global_position + Vector3(0, offset, 0)


func _face_point(point: Vector3) -> void:
	var flat: Vector3 = point - visual.global_position
	flat.y = 0.0
	if flat.length_squared() > 0.01:
		_aim_yaw = atan2(-flat.x, -flat.z)
		_aim_hold = aim_hold_time


func _find_soft_target() -> Node3D:
	if camera_rig == null:
		return null
	var camera_forward: Vector3 = -camera_rig.global_transform.basis.z
	camera_forward.y = 0.0
	camera_forward = camera_forward.normalized()
	var best: Node3D = null
	var best_distance: float = aim_assist_range
	for node in get_tree().get_nodes_in_group("enemies"):
		var enemy: Node3D = node as Node3D
		if enemy == null:
			continue
		var to_enemy: Vector3 = enemy.global_position - visual.global_position
		to_enemy.y = 0.0
		var distance: float = to_enemy.length()
		if distance > best_distance or distance < 0.1:
			continue
		var angle: float = rad_to_deg(camera_forward.angle_to(to_enemy / distance))
		if angle > aim_assist_angle_degrees:
			continue
		best = enemy
		best_distance = distance
	return best


func _face_camera_forward() -> void:
	if camera_rig != null and visual != null:
		_aim_yaw = camera_rig.global_rotation.y
		_aim_hold = aim_hold_time


func _cycle(step: int) -> void:
	if weapons.size() < 2:
		return
	_equip(wrapi(current_index + step, 0, weapons.size()))


func _on_weapon_selected(index: int) -> void:
	equip(index)


## Public switch used by the weapon wheel and direct-select keys.
func equip(index: int) -> void:
	if index >= 0 and index < weapons.size():
		_equip(index)


func _equip(index: int) -> void:
	if index == current_index or _attack_lock > 0.0:
		return
	weapons[current_index].on_unequipped()
	current_index = index
	weapons[current_index].on_equipped()
	weapon_changed.emit(weapons[current_index])
