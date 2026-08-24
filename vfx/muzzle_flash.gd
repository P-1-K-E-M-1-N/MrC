class_name MuzzleFlashVfx
extends Node3D

## Visual-only muzzle flash: pops particles and a short light flash
## whenever the referenced weapon SPENDS ammo. Ammo refills (vendor,
## pickups) also emit ammo_changed, so only a decrease counts as a shot.

@export var weapon: Weapon
@export var flash_energy: float = 2.2
@export var light_fade: float = 0.07

var _last_ammo: int = -1

@onready var _particles: GPUParticles3D = $Flash
@onready var _light: OmniLight3D = $FlashLight


func _ready() -> void:
	if weapon != null:
		_last_ammo = weapon.max_ammo
		weapon.ammo_changed.connect(_on_ammo_changed)


func _on_ammo_changed(current: int, _max_value: int) -> void:
	var fired: bool = current < _last_ammo
	_last_ammo = current
	if not fired:
		return
	_particles.restart()
	_light.light_energy = flash_energy
	var tween: Tween = create_tween()
	tween.tween_property(_light, "light_energy", 0.0, light_fade)
