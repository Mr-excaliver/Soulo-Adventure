shader_type canvas_item;
uniform vec2 center;
uniform float force;
void fragment() {
	vec2 disp = normalize(SCREEN_UV - center) * force;
	COLOR = texture(TEXTURE , SCREEN_UV - disp);
}