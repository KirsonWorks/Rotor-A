shader_type spatial;
render_mode ambient_light_disabled;
uniform sampler2D first_texture : source_color, repeat_enable;
uniform sampler2D second_texture : source_color, repeat_enable;
uniform float height_factor = 1.0;
varying float v_height;

void vertex() {
	v_height = 1.0 - clamp(height_factor / VERTEX.y, 0.0, 1.0);
}

void fragment() {
	vec3 first_color = texture(first_texture, UV).rgb;
	vec3 second_color = texture(second_texture, UV).rgb;
	vec3 mixed_color = mix(first_color, second_color, v_height);
	ALBEDO = mixed_color;
}
