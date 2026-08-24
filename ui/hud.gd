class_name HeroHud
extends CanvasLayer

## Greybox HUD: health, equipped weapon, ammo. Rebuilt every frame —
## trivially cheap and immune to ready-order/signal-timing bugs.

@export var weapon_holder: WeaponHolderComponent
@export var health_component: HealthComponent
@export var wallet: WalletComponent

@onready var _label: Label = $Label


func _process(_delta: float) -> void:
	var bolts_line: String = "Bolts %d" % wallet.bolts if wallet != null else ""
	var weapon: Weapon = weapon_holder.current_weapon()
	if weapon == null:
		_label.text = "HP %d\n%s" % [health_component.current_health, bolts_line]
		return
	var ammo_text: String = "--"
	if weapon.max_ammo < 0:
		ammo_text = "inf"
	else:
		ammo_text = "%d / %d" % [weapon.ammo, weapon.max_ammo]
	var strip: String = ""
	for i in weapon_holder.weapons.size():
		var entry: String = "%d %s" % [i + 1, weapon_holder.weapons[i].display_name]
		if i == weapon_holder.current_index:
			entry = "[%s]" % entry
		strip += entry + "   "
	_label.text = "HP %d\n%s  [%s]\n%s\n%s" % [
		health_component.current_health, weapon.display_name, ammo_text, bolts_line, strip
	]
