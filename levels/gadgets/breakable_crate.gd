class_name BreakableCrate
extends StaticBody3D

## Smashable box: any player attack breaks it, scattering bolts.
## Its hurtbox extends past the body so projectiles register the hit
## before dying on the collision surface.

@export var bolt_drop_scene: PackedScene
@export var min_bolt_drop: int = 2
@export var max_bolt_drop: int = 4
## Chance to drop an ammo pickup INSTEAD of bolts.
@export var ammo_drop_scene: PackedScene
@export var ammo_drop_chance: float = 0.3

@onready var _health: HealthComponent = $HealthComponent
@onready var _mesh: MeshInstance3D = $MeshInstance3D


func _ready() -> void:
	_health.died.connect(_on_broken)
	($HurtboxComponent as HurtboxComponent).hit_received.connect(_on_hit)


func _on_hit(_amount: int) -> void:
	_mesh.scale = Vector3(1.1, 0.92, 1.1)
	var tween: Tween = create_tween()
	tween.tween_property(_mesh, "scale", Vector3.ONE, 0.12)


func _on_broken() -> void:
	if ammo_drop_scene != null and randf() < ammo_drop_chance:
		var ammo: AmmoPickup = ammo_drop_scene.instantiate()
		ammo.position = global_position + Vector3(0, 0.6, 0)
		get_tree().current_scene.add_child(ammo)
	elif bolt_drop_scene != null:
		for i in randi_range(min_bolt_drop, max_bolt_drop):
			var bolt: BoltPickup = bolt_drop_scene.instantiate()
			bolt.position = global_position + Vector3(
				randf_range(-0.6, 0.6), 0.6 + randf() * 0.4, randf_range(-0.6, 0.6)
			)
			get_tree().current_scene.add_child(bolt)
	queue_free()
