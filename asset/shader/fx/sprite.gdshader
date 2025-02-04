shader_type spatial;
render_mode unshaded, blend_add, cull_disabled, fog_disabled;

uniform sampler2D sprite : source_color, filter_linear, repeat_enable, hint_default_black;
uniform vec4 tint: source_color = vec4(1.0);
uniform ivec2 frames;
uniform int frame;
uniform float intensity_min = 0.0;
uniform float intensity_max = 2.0;
uniform float frequency = 1.0;
//uniform bool is_y_billboard = false;
uniform bool is_billboard = true;

void vertex() {
	//if (is_y_billboard)
	//{
	//	MODELVIEW_MATRIX = VIEW_MATRIX * mat4(
	//		vec4(normalize(cross(vec3(0.0, 1.0, 0.0), INV_VIEW_MATRIX[2].xyz)), 0.0), vec4(0.0, 1.0, 0.0, 0.0), vec4(normalize(cross(INV_VIEW_MATRIX[0].xyz, vec3(0.0, 1.0, 0.0))), 0.0), MODEL_MATRIX[3]);
	//}

	if (is_billboard)
	{
		MODELVIEW_MATRIX = VIEW_MATRIX * mat4(
			INV_VIEW_MATRIX[0],
			INV_VIEW_MATRIX[1],
			INV_VIEW_MATRIX[2],
			MODEL_MATRIX[3]
		);

		MODELVIEW_NORMAL_MATRIX = mat3(MODELVIEW_MATRIX);
	}
}

void fragment() {
	int current_frame = frame >= 0 ? frame : int(round(TIME * frequency));
	vec2 n = vec2(max(1.0, float(frames.r)), max(1.0, float(frames.g)));
	vec2 xy = vec2(float(current_frame % frames.r), float(current_frame / frames.g));
	vec4 color = texture(sprite, UV / n + xy / n);
	float t = frequency > 0.0 ? cos(TIME * frequency) : 1.0;

	color.rgb = color.rgb * tint.rgb;
	ALBEDO = color.rgb * (intensity_min + (intensity_max - intensity_min) * t);
	ALPHA = color.a;
}
