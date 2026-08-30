extends Node

## Full-slice integration test: drives the hero through planet_01's
## critical path — arena triggers, gate seals/releases, rewards, vendor
## purchase, exit overlay. Fails loudly if any session breaks the level.
## Run: godot --headless --path . res://tests/slice_walkthrough_test.tscn

const PLANET_SCENE: PackedScene = preload("res://levels/planet_01.tscn")

const ARENA1_ROSTER: Array[String] = ["Rusher1", "Rusher2", "SwarmA1", "SwarmA2", "SwarmA3"]
const ARENA2_ROSTER: Array[String] = ["RusherB1", "ShooterB1", "ShooterB2", "TurretB1"]
const ARENA3_ROSTER: Array[String] = [
	"TurretC1", "TurretC2", "ShooterC1", "RusherC1", "RusherC2",
	"SwarmC1", "SwarmC2", "SwarmC3", "SwarmC4",
]

var _planet: Node3D
var _hero: Hero
var _ticks: int = 0
var _failures: Array[String] = []


func _ready() -> void:
	_planet = PLANET_SCENE.instantiate()
	add_child(_planet)


func _physics_process(_delta: float) -> void:
	_ticks += 1
	match _ticks:
		10:
			_hero = get_tree().get_first_node_in_group("player")
			_check(_hero != null, "hero present in level")
			# The bot validates flow, not survival.
			var health: HealthComponent = _hero.get_node("HealthComponent")
			health.max_health = 100000
			health.current_health = 100000
		20:
			_teleport(Vector3(0, 0.5, -34))
		50:
			_check(_gate("Arena1Volume").collision_layer == 1, "arena 1 sealed on entry")
			_kill(ARENA1_ROSTER)
		80:
			_check(_gate("Arena1Volume").collision_layer == 0, "arena 1 gates dropped")
			# Rewards magnetize into the wallet almost instantly, so count
			# what was collected rather than what is still lying around.
			_check(GameStats.bolts_collected > 0 or _count_bolts() > 0,
				"arena 1 paid a bolt reward")
			_teleport(Vector3(0, 3.5, -80))
		110:
			_check(_gate("Arena2Volume").collision_layer == 1, "arena 2 sealed on entry")
			_kill(ARENA2_ROSTER)
		140:
			_check(_gate("Arena2Volume").collision_layer == 0, "arena 2 gates dropped")
			_teleport(Vector3(0, 3.5, -120))
		170:
			_check(_gate("Arena3Volume").collision_layer == 1, "arena 3 sealed on entry")
			_kill(ARENA3_ROSTER)
		200:
			_check(_gate("Arena3Volume").collision_layer == 0, "arena 3 gates dropped")
			var wallet: WalletComponent = _hero.get_node("WalletComponent")
			wallet.bolts = 0
			wallet.add(20)
			_hero.get_node("HealthComponent").current_health = 50
			var holder: WeaponHolderComponent = _hero.get_node("WeaponHolderComponent")
			holder.weapons[1].ammo = 0
			_teleport(Vector3(-4, 3.5, -141))
		230:
			_hero.get_node("InputComponent").interact_pressed.emit()
		250:
			var wallet: WalletComponent = _hero.get_node("WalletComponent")
			var holder: WeaponHolderComponent = _hero.get_node("WeaponHolderComponent")
			_check(wallet.bolts == 0, "vendor spent the bolts")
			_check(_hero.get_node("HealthComponent").current_health == 100000,
				"vendor restored health")
			_check(holder.weapons[1].ammo == holder.weapons[1].max_ammo,
				"vendor refilled ammo")
			_teleport(Vector3(0, 3.5, -153))
		280:
			var overlay: CanvasLayer = _planet.get_node("ExitVolume/Overlay")
			_check(overlay.visible, "completion overlay shown at exit")
			if _failures.is_empty():
				print("PASS: slice walkthrough")
				get_tree().quit(0)
			else:
				print("FAIL: ", ", ".join(_failures))
				get_tree().quit(1)


func _teleport(point: Vector3) -> void:
	_hero.global_position = point
	_hero.velocity = Vector3.ZERO


func _gate(arena_name: String) -> StaticBody3D:
	return _planet.get_node(arena_name + "/GateIn")


func _kill(roster: Array[String]) -> void:
	for enemy_name in roster:
		var enemy: Node3D = _planet.get_node_or_null(enemy_name)
		if enemy != null:
			enemy.get_node("HealthComponent").take_damage(999999)


func _count_bolts() -> int:
	var count: int = 0
	for child in get_tree().current_scene.get_children():
		if child is BoltPickup:
			count += 1
	for child in _planet.get_children():
		if child is BoltPickup:
			count += 1
	return count


func _check(condition: bool, label: String) -> void:
	print(("ok: " if condition else "FAILED: ") + label)
	if not condition:
		_failures.append(label)
