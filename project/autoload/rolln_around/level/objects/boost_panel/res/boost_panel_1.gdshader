// NOTE: Shader automatically converted from Godot Engine 4.0.alpha14's StandardMaterial3D.

shader_type spatial;
render_mode blend_mix,depth_draw_opaque,cull_back,diffuse_toon,specular_toon;
uniform vec4 top_albedo : source_color = vec4(1.0);
uniform vec4 bottom_albedo : source_color = vec4(1.0);
uniform sampler2D top_texture_albedo : source_color,filter_linear_mipmap,repeat_enable;
uniform sampler2D bottom_texture_albedo : source_color,filter_linear_mipmap,repeat_enable;
uniform float point_size : hint_range(0,128);
uniform float roughness : hint_range(0,1);
uniform sampler2D texture_metallic : hint_default_white,filter_linear_mipmap,repeat_enable;
uniform vec4 metallic_texture_channel;
uniform sampler2D texture_roughness : hint_roughness_r,filter_linear_mipmap,repeat_enable;
uniform float specular;
uniform float metallic;
uniform vec3 uv1_scale;
uniform vec3 uv1_offset;
uniform vec3 uv2_scale;
uniform vec3 uv2_offset;
uniform float speed = 1.0;


void vertex() {
	UV=UV*uv1_scale.xy+uv1_offset.xy;
}






void fragment() {
	vec2 base_uv = UV;
	// Scroll top texture
	vec2 top_uv = base_uv;
	top_uv.y += TIME * speed * 0.5;
	// Get texture and albedo stuff
	vec4 top_albedo_tex = texture(top_texture_albedo, top_uv) * top_albedo;
	vec4 bottom_albedo_tex = texture(bottom_texture_albedo, base_uv) * bottom_albedo;
	vec4 albedo_tex = bottom_albedo_tex;
	// Mix and set albedos
	
//	ALBEDO = mix(top_albedo_tex.rgb, bottom_albedo_tex.rgb, abs(top_albedo_tex.a - 1.0));
	ALBEDO = mix(top_albedo_tex.rgb, bottom_albedo_tex.rgb, abs(top_albedo_tex.a - 1.0));
	EMISSION = mix(top_albedo_tex.rgb, vec3(0.0), abs(top_albedo_tex.a - 1.0));
	float metallic_tex = dot(texture(texture_metallic,base_uv),metallic_texture_channel);
	METALLIC = metallic_tex * metallic;
	vec4 roughness_texture_channel = vec4(1.0,0.0,0.0,0.0);
	float roughness_tex = dot(texture(texture_roughness,base_uv),roughness_texture_channel);
	ROUGHNESS = roughness_tex * roughness;
	SPECULAR = specular;
}
