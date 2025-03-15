shader_type canvas_item;
uniform float speed = 1.0;
uniform float amplitude = 0.02;
void fragment() {
    vec2 uv = UV + vec2(sin(TIME * speed + UV.y * 10.0) * amplitude, cos(TIME * speed + UV.x * 10.0) * amplitude);
    COLOR = texture(TEXTURE, uv);
}