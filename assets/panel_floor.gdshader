shader_type spatial;

// Procedural sci-fi floor panels, gridded in WORLD space so adjoining
// floor boxes of any size tile seamlessly. Dark grooves split the floor
// into panels with slight per-panel value variation; every `trim_every`
// panels a groove glows in `trim_color` so each zone can wear its own
// accent color.
//
// Conduit pulses: bright dashes flow along the glowing trim lines —
// X-running lines flow toward +X, Z-running lines flow toward -Z (the
// direction of travel through the level). `beat_energy` scales their
// brightness and is driven at runtime by ConduitDriver (BPM clock or
// music spectrum), defaulting to a steady glow without a driver.

uniform vec3 base_color : source_color = vec3(0.4, 0.45, 0.55);
uniform vec3 groove_color : source_color = vec3(0.16, 0.18, 0.24);
uniform vec3 trim_color : source_color = vec3(0.2, 0.85, 0.95);
uniform float trim_emission : hint_range(0.0, 6.0) = 2.0;
uniform float tile_size : hint_range(0.5, 8.0) = 2.0;
uniform float groove_width : hint_range(0.01, 0.5) = 0.09;
uniform float trim_every : hint_range(2.0, 16.0) = 4.0;
uniform float trim_width : hint_range(0.02, 0.8) = 0.16;
uniform float panel_variation : hint_range(0.0, 0.5) = 0.12;
uniform vec3 flow_color : source_color = vec3(0.75, 0.95, 1.0);
uniform float flow_emission : hint_range(0.0, 8.0) = 1.8;
uniform float flow_speed : hint_range(0.0, 30.0) = 5.0;
uniform float flow_spacing : hint_range(2.0, 40.0) = 10.0;
uniform float flow_length : hint_range(0.2, 8.0) = 2.2;
uniform float beat_energy : hint_range(0.0, 3.0) = 1.0;

varying vec3 world_pos;

void vertex() {
	world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

float edge_mask(vec2 pos, float spacing, float width) {
	vec2 centered = abs(fract(pos / spacing) - 0.5) * spacing;
	vec2 to_edge = vec2(spacing * 0.5) - centered;
	float d = min(to_edge.x, to_edge.y);
	return 1.0 - smoothstep(width * 0.5, width, d);
}

// Mask for grid lines perpendicular to one axis: 1.0 near coord = k*spacing.
float axis_mask(float coord, float spacing, float width) {
	float centered = abs(fract(coord / spacing) - 0.5) * spacing;
	float to_edge = spacing * 0.5 - centered;
	return 1.0 - smoothstep(width * 0.5, width, to_edge);
}

// Repeating soft pulse travelling toward +coord at flow_speed.
float flow_pulse(float coord) {
	float p = fract((coord - TIME * flow_speed) / flow_spacing) - 0.5;
	float d = p * flow_spacing;
	return exp(-(d * d) / (flow_length * flow_length * 0.25));
}

void fragment() {
	float groove = edge_mask(world_pos.xz, tile_size, groove_width);
	vec2 id = floor(world_pos.xz / tile_size);
	float h = fract(sin(dot(id, vec2(127.1, 311.7))) * 43758.5453);
	vec3 panel = base_color * (1.0 - panel_variation * 0.5 + panel_variation * h);
	ALBEDO = mix(panel, groove_color, groove);
	float spacing = tile_size * trim_every;
	float trim = edge_mask(world_pos.xz, spacing, trim_width);
	float lines_z = axis_mask(world_pos.x, spacing, trim_width);
	float lines_x = axis_mask(world_pos.z, spacing, trim_width);
	float flow = lines_z * flow_pulse(-world_pos.z) + lines_x * flow_pulse(world_pos.x);
	EMISSION = trim_color * trim_emission * trim
		+ flow_color * flow_emission * beat_energy * min(flow, 1.0);
	ROUGHNESS = mix(0.85, 0.6, groove);
	METALLIC = 0.0;
}
