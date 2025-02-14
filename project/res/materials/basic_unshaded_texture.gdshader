shader_type spatial;
render_mode blend_mix,depth_draw_opaque,cull_back,diffuse_burley,specular_disabled,unshaded,ambient_light_disabled,fog_disabled;


global uniform vec3 sun_dir;
uniform sampler2D texture_image: filter_nearest;


void fragment() {
	vec3 texture_color = texture(texture_image, UV).rgb;
	float facing_up = dot(
		NORMAL,
		sun_dir
	);
	facing_up = (facing_up + 1.0) / 2.0;
	// facing_up is:
	// 0.0 if NORMAL is facing down.
	// 1.0 if NORMAL is facing up.
	float shadow = min(
		facing_up + 0.5,
		1.0
	);
	shadow *= shadow;
	texture_color *= shadow;
	ALBEDO = texture_color;
	//ALBEDO = vec3(shadow);
}
