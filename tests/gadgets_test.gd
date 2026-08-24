extends Node

## Headless check of the level gadgets: jump pad launch, breakable crate
## dropping bolts, checkpoint respawn, and vendor refill.
## Run: godot --headless --path . res://tests/gadgets_test.tscn

const HERO_SCENE: PackedScene = preload("res://player/hero.tscn")
const PAD_SCENE: PackedScene = preload("res://levels/gadgets/jump_pad.tscn")
const CRATE_SCENE: PackedScene = preload("res://levels/gadgets/breakable_crate.tscn")
const CHECK_SCENE: PackedScene = preload("res://levels/gadgets/checkpoint.tscn")
const VENDOR_SCENE: PackedScene = preload("res://levels/gadgets/vendor.tscn")

var _hero: Hero
var _health: HealthComponent
var _wallet: WalletComponent
var _crate: BreakableCrate
var _max_hero_y: float = 0.0
var _ticks: int = 0
var _failures: Array[String] = []


func _ready() -> void:
	var floor_body: StaticBody3D = StaticBody3D.new()
	var floor_shape: CollisionShape3D = CollisionShape3D.new()
	var floor_box: BoxShape3D = BoxShape3D.new()
	floor_box.size = Vector3(200, 1, 200)
	floor_shape.shape = floor_box
	floor_body.add_child(floor_shape)
	add_child(floor_body)
	floor_body.position = Vector3(0, -0.5, 0)

	_hero = HERO_SCENE.instantiate()
	_hero.position = Vector3(0, 0.1, 0)
	add_child(_hero)
	_health = _hero.get_node("HealthComponent")
	_wallet = _hero.get_node("WalletComponent")

	var pad: JumpPad = PAD_SCENE.instantiate()
	pad.position = Vector3(0, 0, 0)
	add_child(pad)

	_crate = CRATE_SCENE.instantiate()
	_crate.position = Vector3(30, 0, 0)
	add_child(_crate)

	var checkpoint: Checkpoint = CHECK_SCENE.instantiate()
	checkpoint.position = Vector3(40, 0, 0)
	add_child(checkpoint)

	var vendor: Vendor = VENDOR_SCENE.instantiate()
	vendor.position = Vector3(40, 0, 4)
	add_child(vendor)


func _physics_process(_delta: float) -> void:
	_ticks += 1
	_max_hero_y = maxf(_max_hero_y, _hero.global_position.y)
	match _ticks:
		60:
			_check(_max_hero_y > 3.0, "jump pad launched hero (peak %.1f m)" % _max_hero_y)
			_crate.get_node("HealthComponent").take_damage(10)
		90:
			_check(not is_instance_valid(_crate), "crate broke")
			var found: bool = false
			for child in get_children():
				if child is BoltPickup:
					found = true
			_check(found, "crate dropped bolts")
			_hero.global_position = Vector3(40, 0.1, 0)
			_hero.velocity = Vector3.ZERO
		130:
			_health.take_damage(999)
		140:
			var near: bool = _hero.global_position.distance_to(Vector3(40, 0.3, 0)) < 2.0
			_check(near, "respawned at checkpoint")
			_check(_health.current_health == 100, "respawn restored HP")
			_hero.global_position = Vector3(40, 0.1, 4)
			_hero.velocity = Vector3.ZERO
			_wallet.add(50)
			_health.take_damage(30)
		170:
			_hero.get_node("InputComponent").interact_pressed.emit()
		190:
			_check(_health.current_health == 100, "vendor healed to full")
			_check(_wallet.bolts == 30, "vendor charged 20 bolts")
			if _failures.is_empty():
				print("PASS: gadgets")
				get_tree().quit(0)
			else:
				print("FAIL: ", ", ".join(_failures))
				get_tree().quit(1)


func _check(condition: bool, label: String) -> void:
	print(("ok: " if condition else "FAILED: ") + label)
	if not condition:
		_failures.append(label)
