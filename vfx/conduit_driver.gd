class_name ConduitDriver
extends Node

## Visual-only: throbs the floor conduit pulses (panel_floor.gdshader's
## `beat_energy`). With a music stream assigned it follows the track's
## bass energy through a spectrum analyzer on its own audio bus; without
## one it ticks a steady BPM clock. Attach anywhere in a level and point
## `scan_root` at the node whose floors should pulse.

@export var scan_root: Node3D
@export var music: AudioStream
@export var bpm: float = 110.0
## Conduit brightness floor between beats.
@export var base_level: float = 0.35
## Extra brightness at full beat energy.
@export var beat_gain: float = 1.4
## How fast a beat's brightness falls off, per second.
@export var decay: float = 4.0
## Bass band analyzed for music sync, in Hz.
@export var bass_low: float = 20.0
@export var bass_high: float = 150.0

const BUS_NAME: String = "MusicSync"

var _materials: Array[ShaderMaterial] = []
var _energy: float = 0.0
var _beat_accum: float = 0.0
var _spectrum: AudioEffectSpectrumAnalyzerInstance


func _ready() -> void:
	if scan_root != null:
		_collect_materials(scan_root)
	if music != null:
		_setup_music()


func _process(delta: float) -> void:
	if _spectrum != null:
		var magnitude: Vector2 = _spectrum.get_magnitude_for_frequency_range(bass_low, bass_high)
		var bass: float = clampf(magnitude.length() * 40.0, 0.0, 1.0)
		_energy = maxf(bass, _energy - decay * delta)
	else:
		_beat_accum += delta * bpm / 60.0
		if _beat_accum >= 1.0:
			_beat_accum = fmod(_beat_accum, 1.0)
			_energy = 1.0
		else:
			_energy = maxf(_energy - decay * delta, 0.0)
	var level: float = base_level + beat_gain * _energy
	for material in _materials:
		material.set_shader_parameter(&"beat_energy", level)


## Gather every unique panel-floor ShaderMaterial under `root`.
func _collect_materials(root: Node) -> void:
	var mesh_instance: MeshInstance3D = root as MeshInstance3D
	if mesh_instance != null:
		var material: ShaderMaterial = mesh_instance.get_surface_override_material(0) as ShaderMaterial
		if material != null and material.shader != null \
				and material.shader.resource_path.ends_with("panel_floor.gdshader") \
				and not _materials.has(material):
			_materials.append(material)
	for child in root.get_children():
		_collect_materials(child)


func _setup_music() -> void:
	var bus_index: int = AudioServer.bus_count
	AudioServer.add_bus(bus_index)
	AudioServer.set_bus_name(bus_index, BUS_NAME)
	var analyzer: AudioEffectSpectrumAnalyzer = AudioEffectSpectrumAnalyzer.new()
	AudioServer.add_bus_effect(bus_index, analyzer)
	_spectrum = AudioServer.get_bus_effect_instance(bus_index, 0)
	var player: AudioStreamPlayer = AudioStreamPlayer.new()
	player.stream = music
	player.bus = BUS_NAME
	add_child(player)
	player.play()
