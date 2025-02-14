// NOTE: Shader automatically converted from Godot Engine 4.2.1.stable's StandardMaterial3D.

shader_type spatial;
render_mode blend_mix,depth_draw_opaque,cull_disabled,diffuse_burley,specular_disabled,unshaded,ambient_light_disabled,fog_disabled;
uniform vec3 direction = vec3(1.0, 1.0, 1.0);


void fragment() {
	vec2 sliding_uv = UV + vec2(0.0, TIME);
	vec3 gradient_color = vec3(mod(sliding_uv.y, 1.0) / 0.5 + 0.5);
	float middle = float(UV.y > 0.1 && UV.y < 0.9);
	float top = float(UV.y < 0.1);
	ALBEDO = (normalize(direction) * gradient_color) * middle + top;
}
