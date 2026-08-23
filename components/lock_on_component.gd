class_name LockOnComponent
extends Node

## Q-key target lock. First press locks the nearest enemy in range; while
## locked, pressing again cycles to the next candidate (or unlocks when
## there's nothing to cycle to). Releases itself when the target dies or
## drifts out of break range. Feeds the camera rig, which owns the tracking.

signal target_changed(target: Node3D)

@export var body: CharacterBody3D
@export var input_component: InputComponent
@export var camera_rig: CameraRig
@export var lock_range: float = 15.0
@export var break_range: float = 18.0

var target: Node3D = null

var _indicator: MeshInstance3D


func _ready() -> void:
	input_component.lock_on_pressed.connect(_on_lock_on_pressed)
	_build_indicator()


func _physics_process(delta: float) -> void:
	if target != null and (not is_instance_valid(target) or _distance_to(target) > break_range):
		_set_target(null)
	if target != null:
		_indicator.global_position = target.global_position + Vector3(0, 2.4, 0)
		_indicator.rotation.y += 3.0 * delta


func _on_lock_on_pressed() -> void:
	var candidates: Array[Node3D] = _get_candidates()
	if candidates.is_empty():
		_set_target(null)
		return
	if target == null:
		_set_target(candidates[0])
		return
	var index: int = candidates.find(target)
	var next: Node3D = candidates[(index + 1) % candidates.size()] if index != -1 else candidates[0]
	_set_target(null if next == target else next)


func _get_candidates() -> Array[Node3D]:
	var found: Array[Node3D] = []
	for node in get_tree().get_nodes_in_group("enemies"):
		var enemy: Node3D = node as Node3D
		if enemy != null and _distance_to(enemy) <= lock_range:
			found.append(enemy)
	found.sort_custom(
		func(a: Node3D, b: Node3D) -> bool: return _distance_to(a) < _distance_to(b)
	)
	return found


func _distance_to(node: Node3D) -> float:
	return body.global_position.distance_to(node.global_position)


func _set_target(new_target: Node3D) -> void:
	target = new_target
	camera_rig.lock_target = new_target
	_indicator.visible = new_target != null
	target_changed.emit(new_target)


## Greybox marker: a spinning red diamond floating over the locked target.
func _build_indicator() -> void:
	_indicator = MeshInstance3D.new()
	var box: BoxMesh = BoxMesh.new()
	box.size = Vector3(0.3, 0.3, 0.3)
	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.albedo_color = Color(1.0, 0.2, 0.2)
	material.emission_enabled = true
	material.emission = Color(1.0, 0.15, 0.15)
	material.emission_energy_multiplier = 2.0
	box.material = material
	_indicator.mesh = box
	_indicator.rotation.x = deg_to_rad(45.0)
	_indicator.rotation.z = deg_to_rad(45.0)
	_indicator.top_level = true
	_indicator.visible = false
	body.add_child.call_deferred(_indicator)
