shader_type spatial;
render_mode blend_mix,depth_draw_opaque,cull_disabled,diffuse_burley,specular_schlick_ggx,unshaded,ambient_light_disabled,fog_disabled;


uniform sampler2D text: filter_nearest, repeat_disable;
uniform sampler2D pattern: filter_nearest, repeat_enable;
uniform vec3 uv_scale = vec3(1.0);
uniform vec3 uv_offset = vec3(0.0);
uniform vec3 band_color_1 = vec3(0.95, 0.025, 0.2);
uniform vec3 band_color_2 = vec3(0.75, 0.1, 0.025);


void vertex() {
	UV = UV * uv_scale.xy + uv_offset.xy;
}


void fragment() {
	float front_facing = float(FRONT_FACING);
	float flip = (front_facing * 2.0) - 1.0;
	vec2 pattern_uv = UV - vec2(TIME, TIME / 2.0) / 2.0;
	vec4 pattern_color = texture(pattern, pattern_uv);
	vec2 text_uv = UV * vec2(0.5 * flip, 1.0) + vec2(-(front_facing * 2.5) + 1.75, -2.0);
	vec4 text_color = texture(text, text_uv);
	float band_area = abs(
		round(
			clamp(
				distance(UV.y, 2.5),
				0.0,
				1.0
			)
		) - 1.0
	);
	vec3 band_gradient_color = mix(band_color_1, band_color_2, UV.y - 2.0);
	float text_area_inverse = abs(text_color.a - 1.0);
	vec3 band_color = vec3(0.95, 0.1, 0.1) * band_area * text_area_inverse;
	ALBEDO = (text_color.rgb * text_color.a) + 
		(pattern_color.rgb * text_area_inverse * abs(band_area - 1.0)) +
		(band_gradient_color * band_area * text_area_inverse);
	ALPHA = text_color.a + pattern_color.a + band_area;
}