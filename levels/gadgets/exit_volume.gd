class_name ExitVolume
extends Area3D

## End of the slice: stepping in shows the completion overlay with run stats.

@onready var _overlay: CanvasLayer = $Overlay
@onready var _label: Label = $Overlay/Label


func _ready() -> void:
	_overlay.visible = false
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node3D) -> void:
	if not body is Hero:
		return
	_label.text = "SLICE COMPLETE!\n\nTime %s    Deaths %d\nEnemies defeated %d    Bolts collected %d\n\nThanks for playing, Nick." % [
		GameStats.format_run_time(), GameStats.deaths,
		GameStats.enemies_killed, GameStats.bolts_collected,
	]
	_overlay.visible = true
