shader_type spatial;

// Procedural sci-fi floor panels, gridded in WORLD space so adjoining
// floor boxes of any size tile seamlessly. Dark grooves split the floor
// into panels with slight per-panel value variation; every `trim_every`
// panels a groove glows in `trim_color` so each zone can wear its own
// accent color.

uniform vec3 base_color : source_color = vec3(0.4, 0.45, 0.55);
uniform vec3 groove_color : source_color = vec3(0.16, 0.18, 0.24);
uniform vec3 trim_color : source_color = vec3(0.2, 0.85, 0.95);
uniform float trim_emission : hint_range(0.0, 6.0) = 2.0;
uniform float tile_size : hint_range(0.5, 8.0) = 2.0;
uniform float groove_width : hint_range(0.01, 0.5) = 0.09;
uniform float trim_every : hint_range(2.0, 16.0) = 4.0;
uniform float trim_width : hint_range(0.02, 0.8) = 0.16;
uniform float panel_variation : hint_range(0.0, 0.5) = 0.12;

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

void fragment() {
	float groove = edge_mask(world_pos.xz, tile_size, groove_width);
	vec2 id = floor(world_pos.xz / tile_size);
	float h = fract(sin(dot(id, vec2(127.1, 311.7))) * 43758.5453);
	vec3 panel = base_color * (1.0 - panel_variation * 0.5 + panel_variation * h);
	ALBEDO = mix(panel, groove_color, groove);
	float trim = edge_mask(world_pos.xz, tile_size * trim_every, trim_width);
	EMISSION = trim_color * trim_emission * trim;
	ROUGHNESS = mix(0.85, 0.6, groove);
	METALLIC = 0.0;
}
