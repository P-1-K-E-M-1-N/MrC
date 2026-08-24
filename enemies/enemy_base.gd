class_name EnemyBase
extends CharacterBody3D

## Base for all enemies: gravity, steering helpers for BT tasks, facing
## along movement, hit feedback, and death. Behavior lives in a LimboAI
## behavior tree on the child BTPlayer; the player reference is published
## to its blackboard here.

@export var move_speed: float = 4.0
@export var turn_speed: float = 10.0
## Where player weapons aim on this enemy (chest height above the feet).
@export var aim_height: float = 0.9
@export var bolt_drop_scene: PackedScene
@export var min_bolt_drop: int = 3
@export var max_bolt_drop: int = 6

@onready var health: HealthComponent = $HealthComponent
@onready var bt_player: BTPlayer = $BTPlayer

var _base_gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
var _flash_mesh: MeshInstance3D
var _stagger_timer: float = 0.0


func _ready() -> void:
	add_to_group("enemies")
	health.died.connect(_on_died)
	var hurtbox: HurtboxComponent = get_node("HurtboxComponent")
	hurtbox.hit_received.connect(_on_hit)
	_flash_mesh = get_node_or_null("BodyMesh")
	var player: Node3D = get_tree().get_first_node_in_group("player")
	bt_player.blackboard.set_var(&"player", player)


func _physics_process(delta: float) -> void:
	if global_position.y < -30.0:
		queue_free()
		return
	if not is_on_floor():
		velocity.y -= _base_gravity * delta
	_stagger_timer = maxf(_stagger_timer - delta, 0.0)
	var flat_speed: Vector2 = Vector2(velocity.x, velocity.z)
	if flat_speed.length_squared() > 0.25:
		var target_yaw: float = atan2(-velocity.x, -velocity.z)
		var weight: float = 1.0 - exp(-turn_speed * delta)
		rotation.y = lerp_angle(rotation.y, target_yaw, weight)
	move_and_slide()


## Steering API used by BT tasks: set horizontal velocity toward/away
## from points; gravity and facing are handled here. Knockback stagger
## overrides steering so hits actually move the enemy.
func steer(direction: Vector3, speed: float) -> void:
	if _stagger_timer > 0.0:
		return
	velocity.x = direction.x * speed
	velocity.z = direction.z * speed


func stop() -> void:
	if _stagger_timer > 0.0:
		return
	velocity.x = 0.0
	velocity.z = 0.0


func apply_knockback(impulse: Vector3) -> void:
	velocity += impulse
	_stagger_timer = 0.25


func flat_direction_to(point: Vector3) -> Vector3:
	var to_point: Vector3 = point - global_position
	to_point.y = 0.0
	return to_point.normalized()


func flat_distance_to(point: Vector3) -> float:
	var to_point: Vector3 = point - global_position
	to_point.y = 0.0
	return to_point.length()


func face_point(point: Vector3, delta: float) -> void:
	var direction: Vector3 = flat_direction_to(point)
	if direction == Vector3.ZERO:
		return
	var target_yaw: float = atan2(-direction.x, -direction.z)
	var weight: float = 1.0 - exp(-turn_speed * 1.5 * delta)
	rotation.y = lerp_angle(rotation.y, target_yaw, weight)


func _on_died() -> void:
	GameStats.enemies_killed += 1
	if bolt_drop_scene != null:
		var count: int = randi_range(min_bolt_drop, max_bolt_drop)
		for i in count:
			var bolt: BoltPickup = bolt_drop_scene.instantiate()
			bolt.position = global_position + Vector3(
				randf_range(-0.8, 0.8), 0.5 + randf() * 0.4, randf_range(-0.8, 0.8)
			)
			get_tree().current_scene.add_child(bolt)
	queue_free()


func _on_hit(_amount: int) -> void:
	if _flash_mesh == null:
		return
	_flash_mesh.scale = Vector3(1.2, 0.85, 1.2)
	var tween: Tween = create_tween()
	tween.tween_property(_flash_mesh, "scale", Vector3.ONE, 0.15)
