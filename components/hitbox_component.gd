class_name HitboxComponent
extends Area3D

## Damage dealer for melee swings. Disabled between attacks; activate()
## arms it for one swing and each hurtbox is only hit once per swing.

@export var damage: int = 25

var _already_hit: Array[HurtboxComponent] = []


func _ready() -> void:
	monitoring = false
	area_entered.connect(_on_area_entered)


func activate() -> void:
	_already_hit.clear()
	monitoring = true


func deactivate() -> void:
	monitoring = false


func _on_area_entered(area: Area3D) -> void:
	var hurtbox: HurtboxComponent = area as HurtboxComponent
	if hurtbox == null or hurtbox in _already_hit:
		return
	_already_hit.append(hurtbox)
	hurtbox.receive_hit(damage)
