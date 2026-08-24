class_name Hero
extends CharacterBody3D

## Hero root: group membership for AI targeting, respawn on death or
## falling off the world, and hit feedback. All behavior lives in the
## child components.

const FALL_LIMIT_Y: float = -20.0

@onready var _health: HealthComponent = $HealthComponent
@onready var _hurtbox: HurtboxComponent = $HurtboxComponent
@onready var _visual: Node3D = $Visual
@onready var _camera_rig: CameraRig = $CameraRig

var _spawn_transform: Transform3D


func _ready() -> void:
	add_to_group("player")
	_spawn_transform = global_transform
	_health.died.connect(_respawn)
	_hurtbox.hit_received.connect(_on_hit)


func _physics_process(_delta: float) -> void:
	if global_position.y < FALL_LIMIT_Y:
		_respawn()


## Checkpoints call this to move the respawn point forward.
func set_spawn(spawn: Transform3D) -> void:
	_spawn_transform = spawn


func _respawn() -> void:
	GameStats.deaths += 1
	global_transform = _spawn_transform
	velocity = Vector3.ZERO
	_health.reset()


func _on_hit(_amount: int) -> void:
	_camera_rig.add_trauma(0.45)
	Input.start_joy_vibration(0, 0.5, 0.7, 0.3)
	_visual.scale = Vector3(1.12, 0.92, 1.12)
	var tween: Tween = create_tween()
	tween.tween_property(_visual, "scale", Vector3.ONE, 0.18)
