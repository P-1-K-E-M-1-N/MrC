extends Node

## Headless check: swarmlings chase and bite the hero, and a killed
## swarmling drops bolts that magnetize into the hero's wallet.
## Run: godot --headless --path . res://tests/swarm_test.tscn

const HERO_SCENE: PackedScene = preload("res://player/hero.tscn")
const SWARM_SCENE: PackedScene = preload("res://enemies/swarmling.tscn")

var _hero: Hero
var _wallet: WalletComponent
var _biter: EnemyBase
var _victim: EnemyBase
var _ticks: int = 0


func _ready() -> void:
	var floor_body: StaticBody3D = StaticBody3D.new()
	var floor_shape: CollisionShape3D = CollisionShape3D.new()
	var floor_box: BoxShape3D = BoxShape3D.new()
	floor_box.size = Vector3(100, 1, 100)
	floor_shape.shape = floor_box
	floor_body.add_child(floor_shape)
	add_child(floor_body)
	floor_body.position = Vector3(0, -0.5, 0)

	_hero = HERO_SCENE.instantiate()
	_hero.position = Vector3(0, 0.1, 0)
	add_child(_hero)
	_wallet = _hero.get_node("WalletComponent")

	_biter = SWARM_SCENE.instantiate()
	_biter.position = Vector3(6, 0.1, 0)
	add_child(_biter)

	_victim = SWARM_SCENE.instantiate()
	_victim.position = Vector3(0, 0.1, 3)
	add_child(_victim)


func _physics_process(_delta: float) -> void:
	_ticks += 1
	if _ticks == 30:
		_victim.health.take_damage(999)
	if _ticks < 360:
		return
	var hp: int = _hero.get_node("HealthComponent").current_health
	var bitten: bool = hp < 100
	var paid: bool = _wallet.bolts >= 1
	print("hero HP %d (want < 100), wallet %d bolts (want >= 1)" % [hp, _wallet.bolts])
	if bitten and paid:
		print("PASS: swarmling and bolt drops")
		get_tree().quit(0)
	else:
		print("FAIL: swarmling and bolt drops")
		get_tree().quit(1)
