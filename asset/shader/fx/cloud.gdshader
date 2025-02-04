shader_type canvas_item;

uniform vec2 offset;
uniform vec2 wind_direction = vec2(1.0, 1.0);
uniform float wind_speed = 1.0;

void fragment()
{
	COLOR = texture(TEXTURE, UV + offset + TIME * wind_speed * wind_direction);
}
