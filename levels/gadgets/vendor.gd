class_name Vendor
extends Area3D

## Refill kiosk: while the hero stands in range, pressing interact spends
## bolts to restore full health and all weapon ammo.

@export var refill_cost: int = 20

@onready var _label: Label3D = $Label3D

var _hero: Hero


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	_label.text = "REFILL: %d BOLTS\n[E]" % refill_cost


func _on_body_entered(body: Node3D) -> void:
	var hero: Hero = body as Hero
	if hero == null:
		return
	_hero = hero
	var input: InputComponent = hero.get_node("InputComponent")
	input.interact_pressed.connect(_on_interact)


func _on_body_exited(body: Node3D) -> void:
	if body != _hero or _hero == null:
		return
	var input: InputComponent = _hero.get_node("InputComponent")
	input.interact_pressed.disconnect(_on_interact)
	_hero = null


func _on_interact() -> void:
	if _hero == null:
		return
	var wallet: WalletComponent = _hero.get_node("WalletComponent")
	if not wallet.try_spend(refill_cost):
		_flash("NOT ENOUGH BOLTS!")
		return
	var health: HealthComponent = _hero.get_node("HealthComponent")
	health.heal(health.max_health)
	var holder: WeaponHolderComponent = _hero.get_node("WeaponHolderComponent")
	for weapon in holder.weapons:
		if weapon.max_ammo >= 0:
			weapon.ammo = weapon.max_ammo
			weapon.ammo_changed.emit(weapon.ammo, weapon.max_ammo)
	_flash("REFILLED!")


func _flash(message: String) -> void:
	_label.text = message
	var tween: Tween = create_tween()
	tween.tween_interval(1.2)
	tween.tween_callback(func() -> void:
		_label.text = "REFILL: %d BOLTS\n[E]" % refill_cost
	)
