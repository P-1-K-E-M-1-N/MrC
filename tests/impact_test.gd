extends Node

## Headless check: hits knock enemies back (stagger overrides steering),
## ammo pickups refill guns, and run stats feed the completion screen.
## Run: godot --headless --path . res://tests/impact_test.tscn

const HERO_SCENE: PackedScene = preload("res://player/hero.tscn")
const RUSHER_SCENE: PackedScene = preload("res://enemies/rusher.tscn")
const AMMO_SCENE: PackedScene = preload("res://pickups/ammo_pickup.tscn")
const EXIT_SCENE: PackedScene = preload("res://levels/gadgets/exit_volume.tscn")

var _hero: Hero
var _rusher: EnemyBase
var _blaster: Weapon
var _exit: ExitVolume
var _rusher_start_x: float = 40.0
var _ticks: int = 0
var _failures: Array[String] = []


func _ready() -> void:
	var floor_body: StaticBody3D = StaticBody3D.new()
	var floor_shape: CollisionShape3D = CollisionShape3D.new()
	var floor_box: BoxShape3D = BoxShape3D.new()
	floor_box.size = Vector3(300, 1, 300)
	floor_shape.shape = floor_box
	floor_body.add_child(floor_shape)
	add_child(floor_body)
	floor_body.position = Vector3(0, -0.5, 0)

	_hero = HERO_SCENE.instantiate()
	_hero.position = Vector3(0, 0.1, 0)
	add_child(_hero)

	# Far away so it idles (outside aggro range) — knockback must move it.
	_rusher = RUSHER_SCENE.instantiate()
	_rusher.position = Vector3(_rusher_start_x, 0.1, 0)
	add_child(_rusher)

	_exit = EXIT_SCENE.instantiate()
	_exit.position = Vector3(-30, 0, 0)
	add_child(_exit)


func _physics_process(_delta: float) -> void:
	_ticks += 1
	match _ticks:
		20:
			var hurtbox: HurtboxComponent = _rusher.get_node("HurtboxComponent")
			hurtbox.receive_hit(5, _rusher.global_position + Vector3(-2, 0.5, 0))
		50:
			var pushed: float = _rusher.global_position.x - _rusher_start_x
			_check(pushed > 0.25, "knockback moved enemy %.2f m away" % pushed)
			var holder: WeaponHolderComponent = _hero.get_node("WeaponHolderComponent")
			_blaster = holder.weapons[1]
			_blaster.ammo = 0
			var ammo: AmmoPickup = AMMO_SCENE.instantiate()
			ammo.position = _hero.global_position + Vector3(0, 1, 0)
			add_child(ammo)
		90:
			_check(_blaster.ammo == 50, "ammo pickup refilled 25%% (got %d)" % _blaster.ammo)
			_hero.get_node("HealthComponent").take_damage(999)
			_rusher.health.take_damage(999)
		120:
			_check(GameStats.deaths >= 1, "death counted")
			_check(GameStats.enemies_killed >= 1, "kill counted")
			_hero.global_position = Vector3(-30, 0.1, 0)
			_hero.velocity = Vector3.ZERO
		150:
			var overlay: CanvasLayer = _exit.get_node("Overlay")
			var label: Label = _exit.get_node("Overlay/Label")
			_check(overlay.visible, "completion overlay shown")
			_check("Deaths" in label.text and "Bolts" in label.text,
				"completion screen shows run stats")
			if _failures.is_empty():
				print("PASS: impact and completion")
				get_tree().quit(0)
			else:
				print("FAIL: ", ", ".join(_failures))
				get_tree().quit(1)


func _check(condition: bool, label: String) -> void:
	print(("ok: " if condition else "FAILED: ") + label)
	if not condition:
		_failures.append(label)
