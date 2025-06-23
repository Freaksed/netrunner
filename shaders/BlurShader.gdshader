shader_type canvas_item;

uniform float blur_radius = 2.0;

void fragment() {
	vec2 uv = SCREEN_UV;
	vec4 sum = vec4(0.0);
	float total = 0.0;

	for (int x = -4; x <= 4; x++) {
		for (int y = -4; y <= 4; y++) {
			vec2 offset = vec2(x, y) * blur_radius / 512.0;
			sum += textureLod(SCREEN_TEXTURE, uv + offset, 0.0);
			total += 1.0;
		}
	}
	COLOR = sum / total;
}

