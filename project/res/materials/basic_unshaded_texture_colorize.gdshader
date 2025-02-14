shader_type spatial;
render_mode blend_mix,depth_draw_opaque,cull_back,diffuse_burley,specular_disabled,unshaded,ambient_light_disabled,fog_disabled;


uniform sampler2D texture_image: filter_nearest;
uniform vec3 color: source_color = vec3(1.0, 0.0, 0.0);


void fragment() {
	ALBEDO = texture(texture_image, UV).rgb * color;
}
