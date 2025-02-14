// NOTE: Shader automatically converted from Godot Engine 4.0.alpha10's StandardMaterial3D.

shader_type spatial;
render_mode blend_mix,depth_draw_opaque,cull_back,diffuse_toon,specular_toon;
uniform vec4 albedo : source_color = vec4(1.0);
uniform sampler2D texture_albedo : source_color,filter_linear_mipmap,repeat_enable;
uniform float point_size : hint_range(0,128);
uniform float roughness : hint_range(0,1);
uniform sampler2D texture_metallic : hint_default_white,filter_linear_mipmap,repeat_enable;
uniform vec4 metallic_texture_channel;
uniform sampler2D texture_roughness : hint_roughness_r,filter_linear_mipmap,repeat_enable;
uniform float specular;
uniform float metallic;
uniform vec3 uv1_scale = vec3(1);
uniform vec3 uv1_offset;
uniform vec3 uv2_scale = vec3(1);
uniform vec3 uv2_offset;

void vertex() {
	UV=UV*uv1_scale.xy+uv1_offset.xy;
	// Flag wave
	// First part is speed and intensity, second is keeping the flag on the pole
	float displacement = (sin(TIME * 2.0 + (VERTEX.x)) / 2.0) * min(VERTEX.x * 2.0, 1.0);
	VERTEX.z += displacement;
}

void fragment() {
	vec4 albedo_tex = texture(texture_albedo, UV);
	ALBEDO = albedo.rgb * albedo_tex.rgb;
	EMISSION = ALBEDO / 2.0;
	ALPHA *= albedo.a * albedo_tex.a;
	
	float metallic_tex = dot(texture(texture_metallic,UV),metallic_texture_channel);
	METALLIC = metallic_tex * metallic;
	vec4 roughness_texture_channel = vec4(1.0,0.0,0.0,0.0);
	float roughness_tex = dot(texture(texture_roughness,UV),roughness_texture_channel);
	ROUGHNESS = roughness_tex * roughness;
	SPECULAR = specular;
}
