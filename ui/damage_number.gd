class_name DamageNumber
extends Label3D

## Floating hit feedback: rises, fades, frees itself.

const DURATION: float = 0.7
const RISE_SPEED: float = 2.0

var _life: float = 0.0


static func create(amount: int) -> DamageNumber:
	var number: DamageNumber = DamageNumber.new()
	number.text = str(amount)
	number.font_size = 120
	number.pixel_size = 0.004
	number.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	number.no_depth_test = true
	number.modulate = Color(1.0, 0.85, 0.2)
	number.outline_size = 32
	number.outline_modulate = Color(0.1, 0.05, 0.0)
	return number


func _process(delta: float) -> void:
	position.y += RISE_SPEED * delta
	_life += delta
	modulate.a = 1.0 - _life / DURATION
	outline_modulate.a = modulate.a
	if _life >= DURATION:
		queue_free()
