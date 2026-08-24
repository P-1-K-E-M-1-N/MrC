class_name Grenade
extends Area3D

## Lobbed ballistic bomb: flies an arc under gravity, detonates on
## contact with world or enemies, or when the fuse runs out.

@export var initial_speed: float = 8.0
@export var arc_up: float = 5.5
@export var fuse: float = 2.0
@export var spin_speed: float = 8.0
@export var explosion_scene: PackedScene

var _velocity: Vector3 = Vector3.ZERO
var _gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
var _exploded: bool = false


func launch(direction: Vector3) -> void:
	_velocity = direction * initial_speed + Vector3.UP * arc_up


func _ready() -> void:
	body_entered.connect(func(_body: Node3D) -> void: _explode())
	area_entered.connect(func(_area: Area3D) -> void: _explode())
	get_tree().create_timer(fuse).timeout.connect(_explode)


func _physics_process(delta: float) -> void:
	_velocity.y -= _gravity * delta
	global_position += _velocity * delta
	rotation.x += spin_speed * delta


func _explode() -> void:
	if _exploded:
		return
	_exploded = true
	var explosion: Explosion = explosion_scene.instantiate()
	explosion.position = global_position
	get_tree().current_scene.add_child(explosion)
	queue_free()
