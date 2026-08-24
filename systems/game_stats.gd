extends Node

## Run-wide stats singleton (autoload "GameStats"). Fed by hero respawn,
## enemy deaths, and wallet pickups; read by the completion screen.

var run_start_msec: int = 0
var deaths: int = 0
var enemies_killed: int = 0
var bolts_collected: int = 0


func _ready() -> void:
	run_start_msec = Time.get_ticks_msec()


func run_time_seconds() -> float:
	return float(Time.get_ticks_msec() - run_start_msec) / 1000.0


func format_run_time() -> String:
	var total: int = int(run_time_seconds())
	return "%d:%02d" % [total / 60, total % 60]
