class_name AmmoPickup
extends Area3D

## Restores a fraction of max ammo to every gun. Ignored when all
## magazines are already full.

@export var refill_fraction: float = 0.25
@export var bob_height: float = 0.15
@export var spin_speed: float = 2.0

var _base_y: float
var _time: float = 0.0


func _ready() -> void:
	_base_y = position.y
	body_entered.connect(_on_body_entered)


func _process(delta: float) -> void:
	_time += delta
	position.y = _base_y + sin(_time * 2.5) * bob_height
	rotation.y += spin_speed * delta


func _on_body_entered(body: Node3D) -> void:
	var holder: WeaponHolderComponent = body.get_node_or_null("WeaponHolderComponent") as WeaponHolderComponent
	if holder == null:
		return
	var refilled: bool = false
	for weapon in holder.weapons:
		if weapon.max_ammo >= 0 and weapon.ammo < weapon.max_ammo:
			weapon.ammo = mini(
				weapon.ammo + ceili(weapon.max_ammo * refill_fraction), weapon.max_ammo
			)
			weapon.ammo_changed.emit(weapon.ammo, weapon.max_ammo)
			refilled = true
	if refilled:
		queue_free()
