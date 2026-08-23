class_name HeroHud
extends CanvasLayer

## Greybox HUD: health, equipped weapon, ammo. Rebuilt every frame —
## trivially cheap and immune to ready-order/signal-timing bugs.

@export var weapon_holder: WeaponHolderComponent
@export var health_component: HealthComponent

@onready var _label: Label = $Label


func _process(_delta: float) -> void:
	var weapon: Weapon = weapon_holder.current_weapon()
	if weapon == null:
		_label.text = "HP %d" % health_component.current_health
		return
	var ammo_text: String = "--"
	if weapon.max_ammo < 0:
		ammo_text = "inf"
	else:
		ammo_text = "%d / %d" % [weapon.ammo, weapon.max_ammo]
	_label.text = "HP %d\n%s  [%s]" % [
		health_component.current_health, weapon.display_name, ammo_text
	]
