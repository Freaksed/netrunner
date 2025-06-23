shader_type spatial;
render_mode blend_mix;

uniform sampler2D top_texture;
uniform vec3 top_face_normal = vec3(0.0, 1.0, 0.0); // world up
uniform float stripe_density = 5.0;
uniform float stripe_thickness = 0.5;
uniform vec3 stripe_light = vec3(0.7);
uniform vec3 stripe_dark = vec3(0.2);

// Pass from vertex to fragment
varying vec3 world_pos;
varying vec3 world_normal;

void vertex() {
	world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	world_normal = normalize((MODEL_MATRIX * vec4(NORMAL, 0.0)).xyz);
}

void fragment() {
	bool is_top = dot(world_normal, top_face_normal) > 0.9;
	bool is_side = abs(world_normal.y) < 0.1;

	if (is_top) {
		vec2 cropped_uv = (UV - vec2(0.666,0)) * vec2(2.99, 2.0);
		cropped_uv = clamp(cropped_uv, vec2(0.0), vec2(1.0));
		ALBEDO = texture(top_texture, cropped_uv).rgb;
	}
	else if (is_side) {
		float stripe = step(stripe_thickness, fract(world_pos.y * stripe_density));
		ALBEDO = mix(stripe_light, stripe_dark, stripe);
	}
	else {
		ALBEDO = vec3(0.3); // bottom or non-target face
	}
}
