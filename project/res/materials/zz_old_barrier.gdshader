// NOTE: Shader automatically converted from Godot Engine 4.0.alpha16's StandardMaterial3D.

shader_type spatial;
render_mode blend_mix,depth_draw_opaque,cull_disabled,diffuse_toon,specular_toon;

uniform vec3 color_1: source_color = vec3(1.0);
uniform vec3 color_2: source_color = vec3(0.0);

uniform float pattern_scale = 1.0;
const float pattern_scale_modifier = 20.0;
uniform float alpha = 0.8;
varying vec3 true_vertex;


void fragment() {
	vec2 base_uv = UV;
	ALBEDO = vec3(0.0);
	float speed = 0.5;
	// I was initially was trying to make a line with the UV but I came
	// up with this. Don't know what to call it.
	vec2 a = sin((abs(UV - 0.5) * pattern_scale_modifier) + (TIME * speed) * 3.14);
	// The value of the pattern in only 0.0 and 1.0
	float hard_value = step(a.x, a.y);
//	float b = smoothstep(a.x, a.y, 0.0);
	// Create the color from 2 other colors
	ALBEDO = mix(color_1, color_2, hard_value);
	ALPHA = alpha;
}
