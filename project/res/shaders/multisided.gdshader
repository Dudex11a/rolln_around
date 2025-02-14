// NOTE: Shader automatically converted from Godot Engine 4.0.alpha13's StandardMaterial3D.

shader_type spatial;
render_mode blend_mix,depth_draw_opaque,cull_back,diffuse_toon,specular_toon;

uniform float slope_factor = 8.0;
uniform sampler2D texture_albedo_top : source_color,filter_linear_mipmap_anisotropic,repeat_enable;
uniform sampler2D texture_albedo_side : source_color,filter_linear_mipmap_anisotropic,repeat_enable;
uniform sampler2D texture_albedo_bottom : source_color,filter_linear_mipmap_anisotropic,repeat_enable;

uniform vec4 albedo : source_color = vec4(1.0);
//uniform sampler2D texture_albedo : source_color,filter_linear_mipmap_anisotropic,repeat_enable;
uniform float roughness : hint_range(0,1);
uniform float specular;
uniform float metallic;
varying vec3 uv1_triplanar_pos;
uniform float uv1_blend_sharpness = 1.0;
varying vec3 uv1_power_normal;
//varying vec3 uv2_triplanar_pos;
//uniform float uv2_blend_sharpness = 1.0;
//varying vec3 uv2_power_normal;
uniform vec3 uv1_scale = vec3(1);
uniform vec3 uv1_offset = vec3(0);
//uniform vec3 uv2_scale = vec3(1);
//uniform vec3 uv2_offset = vec3(0);

varying vec3 normal;

void vertex() {
	TANGENT = vec3(0.0,0.0,-1.0) * abs(NORMAL.x);
	TANGENT+= vec3(1.0,0.0,0.0) * abs(NORMAL.y);
	TANGENT+= vec3(1.0,0.0,0.0) * abs(NORMAL.z);
	TANGENT = normalize(TANGENT);
	BINORMAL = vec3(0.0,1.0,0.0) * abs(NORMAL.x);
	BINORMAL+= vec3(0.0,0.0,-1.0) * abs(NORMAL.y);
	BINORMAL+= vec3(0.0,1.0,0.0) * abs(NORMAL.z);
	BINORMAL = normalize(BINORMAL);
	uv1_power_normal=pow(abs(NORMAL),vec3(uv1_blend_sharpness));
	uv1_triplanar_pos = VERTEX * uv1_scale + uv1_offset;
	uv1_power_normal/=dot(uv1_power_normal,vec3(1.0));
	uv1_triplanar_pos *= vec3(1.0,-1.0, 1.0);
//	uv2_power_normal=pow(abs(NORMAL), vec3(uv2_blend_sharpness));
//	uv2_triplanar_pos = VERTEX * uv2_scale + uv2_offset;
//	uv2_power_normal/=dot(uv2_power_normal,vec3(1.0));
//	uv2_triplanar_pos *= vec3(1.0,-1.0, 1.0);
	
	normal = NORMAL;
}




vec4 triplanar_texture(sampler2D p_sampler,vec3 p_weights,vec3 p_triplanar_pos) {
	vec4 samp=vec4(0.0);
	samp+= texture(p_sampler,p_triplanar_pos.xy) * p_weights.z;
	samp+= texture(p_sampler,p_triplanar_pos.xz) * p_weights.y;
	samp+= texture(p_sampler,p_triplanar_pos.zy * vec2(-1.0,1.0)) * p_weights.x;
	return samp;
}


float get_top_slope_of_terrain(float height_normal){
	float slope = 1.0 - height_normal;
	slope *= slope;
	return (slope * slope_factor);
}


float get_bottom_slope_of_terrain(float height_normal){
	float slope = 1.0 + height_normal;
	slope *= slope;
	return (slope * slope_factor);
}


void fragment() {
	// Create textures
	vec4 top_albedo_tex = triplanar_texture(texture_albedo_top,uv1_power_normal,uv1_triplanar_pos);
	vec4 side_albedo_tex = triplanar_texture(texture_albedo_side,uv1_power_normal,uv1_triplanar_pos);
	vec4 bottom_albedo_tex = triplanar_texture(texture_albedo_bottom,uv1_power_normal,uv1_triplanar_pos);
	// Get slopes for top and bottom
	float slope_top_factor = clamp(get_top_slope_of_terrain(normal.y), 0.0, 1.0);
	float slope_bottom_factor = clamp(get_bottom_slope_of_terrain(normal.y), 0.0, 1.0);
	// Combine textures, start with wall, then add top and bottom
	vec4 albedo_tex = mix(top_albedo_tex, side_albedo_tex, slope_top_factor);
	albedo_tex = mix(bottom_albedo_tex, albedo_tex, slope_bottom_factor);
	ALBEDO = albedo.rgb * albedo_tex.rgb;
	METALLIC = metallic;
//	vec4 roughness_texture_channel = vec4(1.0,0.0,0.0,0.0);
	ROUGHNESS = roughness;
	SPECULAR = specular;
}
