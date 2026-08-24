class_name ArenaVolume
extends Area3D

## Combat arena: when the hero steps in, energy gates seal the exits
## until every listed enemy is dead, then the gates drop and a bolt
## fountain pays out. Gate nodes are StaticBody3D children; enemies are
## referenced by path so levels stay plain text.

signal cleared

@export var gate_paths: Array[NodePath] = []
@export var enemy_paths: Array[NodePath] = []
@export var bolt_reward_scene: PackedScene
@export var reward_count: int = 5

var _gates: Array[StaticBody3D] = []
var _started: bool = false
var _finished: bool = false
var _remaining: int = 0


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	for path in gate_paths:
		var gate: StaticBody3D = get_node(path)
		_gates.append(gate)
		_set_gate_active(gate, false)


func _on_body_entered(body: Node3D) -> void:
	if _started or not body is Hero:
		return
	_started = true
	for path in enemy_paths:
		var enemy: Node3D = get_node_or_null(path)
		if enemy != null:
			_remaining += 1
			enemy.tree_exited.connect(_on_enemy_gone)
	if _remaining == 0:
		_finish()
		return
	for gate in _gates:
		_set_gate_active(gate, true)


func _on_enemy_gone() -> void:
	if not is_inside_tree():
		return
	_remaining -= 1
	if _remaining <= 0:
		_finish()


func _finish() -> void:
	if _finished:
		return
	_finished = true
	for gate in _gates:
		if is_instance_valid(gate):
			_set_gate_active(gate, false)
	if bolt_reward_scene != null:
		for i in reward_count:
			var bolt: Node3D = bolt_reward_scene.instantiate()
			bolt.position = global_position + Vector3(
				randf_range(-1.5, 1.5), 1.0 + randf(), randf_range(-1.5, 1.5)
			)
			get_tree().current_scene.add_child(bolt)
	cleared.emit()


func _set_gate_active(gate: StaticBody3D, active: bool) -> void:
	gate.visible = active
	gate.collision_layer = 1 if active else 0
