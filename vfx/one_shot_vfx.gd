class_name OneShotVfx
extends Node3D

## Self-running one-shot effect. On enter: restarts every GPUParticles3D
## child, fades every OmniLight3D child to zero, and expands/fades any
## MeshInstance3D child whose name starts with "Ring". Frees itself after
## `lifetime` via a child Timer so nothing dangles if a parent frees us
## first.

@export var lifetime: float = 0.8
@export var light_fade: float = 0.12
@export var ring_end_scale: float = 5.0
@export var ring_grow_time: float = 0.25


func _ready() -> void:
	for child in get_children():
		var particles: GPUParticles3D = child as GPUParticles3D
		if particles != null:
			particles.restart()
			continue
		var light: OmniLight3D = child as OmniLight3D
		if light != null:
			var tween: Tween = create_tween()
			tween.tween_property(light, "light_energy", 0.0, light_fade)
			continue
		var mesh: MeshInstance3D = child as MeshInstance3D
		if mesh != null and String(mesh.name).begins_with("Ring"):
			_grow_ring(mesh)
	var timer: Timer = Timer.new()
	timer.wait_time = lifetime
	timer.one_shot = true
	timer.autostart = true
	timer.timeout.connect(queue_free)
	add_child(timer)


## Give the ring its own material copy so fading it never dims other
## instances sharing the resource.
func _grow_ring(mesh: MeshInstance3D) -> void:
	var material: StandardMaterial3D = mesh.get_active_material(0) as StandardMaterial3D
	if material != null:
		material = material.duplicate() as StandardMaterial3D
		mesh.material_override = material
	mesh.scale = Vector3.ONE * 0.1
	var tween: Tween = create_tween().set_parallel(true)
	var grow: PropertyTweener = tween.tween_property(
		mesh, "scale", Vector3.ONE * ring_end_scale, ring_grow_time
	)
	grow.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	if material != null:
		tween.tween_property(material, "albedo_color:a", 0.0, ring_grow_time)
