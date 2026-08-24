class_name DamageVfx
extends Node

## Visual-only damage feedback: spawns impact sparks on every hit the
## hurtbox reports and a death poof when the health pool empties. Attach
## as an extra child of any character; wires up via exported references,
## never touches gameplay.

const IMPACT_SPARKS: PackedScene = preload("res://vfx/impact_sparks.tscn")
const DEATH_POOF: PackedScene = preload("res://vfx/death_poof.tscn")

@export var hurtbox: HurtboxComponent
@export var health: HealthComponent
## Height above the character origin where sparks pop (chest-ish).
@export var spark_height: float = 0.9
## Disable for the hero — respawn shouldn't look like an enemy kill.
@export var poof_on_death: bool = true
## Scales the death poof for small or large characters.
@export var poof_scale: float = 1.0


func _ready() -> void:
	if hurtbox != null:
		hurtbox.hit_received.connect(_on_hit)
	if health != null and poof_on_death:
		health.died.connect(_on_died)


func _on_hit(_amount: int) -> void:
	var jitter: Vector3 = Vector3(randf_range(-0.25, 0.25), 0.0, randf_range(-0.25, 0.25))
	_spawn(IMPACT_SPARKS, hurtbox.global_position + Vector3(0.0, spark_height, 0.0) + jitter)


func _on_died() -> void:
	var poof: Node3D = _spawn(DEATH_POOF, hurtbox.global_position + Vector3(0.0, spark_height, 0.0))
	poof.scale = Vector3.ONE * poof_scale


func _spawn(scene: PackedScene, at: Vector3) -> Node3D:
	var vfx: Node3D = scene.instantiate()
	vfx.position = at
	get_tree().current_scene.add_child(vfx)
	return vfx
