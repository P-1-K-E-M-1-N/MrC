class_name WeaponWheel
extends CanvasLayer

## Hold-to-open radial weapon select. While the wheel is held open, time
## slows; flick the mouse (or right stick) toward a slot and release to
## equip it. Slots: 0 up, 1 right, 2 down, 3 left.

@export var weapon_holder: WeaponHolderComponent
@export var slow_time_scale: float = 0.25
## Flick distance before a slot is considered picked.
@export var pick_threshold: float = 40.0

@onready var _slots: Array[Label] = [
	$Root/Center/Slot0, $Root/Center/Slot1, $Root/Center/Slot2, $Root/Center/Slot3,
]

var _open: bool = false
var _point: Vector2 = Vector2.ZERO
var _selection: int = -1


func _ready() -> void:
	visible = false


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("weapon_wheel") and not get_tree().paused:
		_open_wheel()
	elif event.is_action_released("weapon_wheel") and _open:
		_close_wheel()
	elif _open and event is InputEventMouseMotion:
		var motion: InputEventMouseMotion = event
		_point = (_point + motion.relative).limit_length(160.0)


func _process(_delta: float) -> void:
	if not _open:
		return
	var stick: Vector2 = Input.get_vector("camera_left", "camera_right", "camera_up", "camera_down")
	if stick.length() > 0.5:
		_point = stick * 160.0
	if _point.length() >= pick_threshold:
		var angle: float = rad_to_deg(atan2(_point.x, -_point.y))
		_selection = wrapi(roundi(angle / 90.0), 0, 4)
	_refresh()


func _open_wheel() -> void:
	_open = true
	visible = true
	_point = Vector2.ZERO
	_selection = weapon_holder.current_index
	Engine.time_scale = slow_time_scale
	_refresh()


func _close_wheel() -> void:
	_open = false
	visible = false
	Engine.time_scale = 1.0
	weapon_holder.equip(_selection)


func _refresh() -> void:
	for i in _slots.size():
		var label: Label = _slots[i]
		if i >= weapon_holder.weapons.size():
			label.text = "-"
			label.modulate = Color(1, 1, 1, 0.2)
			continue
		var weapon: Weapon = weapon_holder.weapons[i]
		var ammo: String = "inf" if weapon.max_ammo < 0 else str(weapon.ammo)
		label.text = "%s\n[%s]" % [weapon.display_name, ammo]
		if i == _selection:
			label.modulate = Color(1, 0.85, 0.2)
		elif i == weapon_holder.current_index:
			label.modulate = Color(0.6, 0.9, 1.0)
		else:
			label.modulate = Color(1, 1, 1, 0.75)
