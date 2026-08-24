class_name WrenchProjectile
extends Area3D

## Thrown wrench: flies straight out to max_range damaging enemy
## hurtboxes, then homes back to the wielder (fresh damage pass on the
## way home). Passes through world geometry so it always returns.

signal returned

@export var out_speed: float = 18.0
@export var return_speed: float = 22.0
@export var max_range: float = 10.0
@export var damage: int = 25
@export var spin_speed: float = 18.0

var _wielder: Node3D
var _direction: Vector3
var _travelled: float = 0.0
var _returning: bool = false
var _already_hit: Array[HurtboxComponent] = []


func setup(wielder: Node3D, direction: Vector3) -> void:
	_wielder = wielder
	_direction = direction.normalized()


func _ready() -> void:
	area_entered.connect(_on_area_entered)


func _physics_process(delta: float) -> void:
	rotation.y += spin_speed * delta
	if not _returning:
		var step: Vector3 = _direction * out_speed * delta
		global_position += step
		_travelled += step.length()
		if _travelled >= max_range:
			_returning = true
			_already_hit.clear()
		return
	if not is_instance_valid(_wielder):
		queue_free()
		return
	var target: Vector3 = _wielder.global_position + Vector3(0, 1, 0)
	if global_position.distance_to(target) <= 0.9:
		returned.emit()
		queue_free()
		return
	global_position += global_position.direction_to(target) * return_speed * delta


func _on_area_entered(area: Area3D) -> void:
	var hurtbox: HurtboxComponent = area as HurtboxComponent
	if hurtbox == null or hurtbox in _already_hit:
		return
	_already_hit.append(hurtbox)
	hurtbox.receive_hit(damage, global_position)
