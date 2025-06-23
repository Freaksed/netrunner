shader_type spatial;
render_mode cull_disabled, blend_mix;

uniform sampler2D front_tex;
uniform sampler2D back_tex;


void fragment() {
	vec2 back_uv = vec2(1.0 - UV.x, UV.y);

	vec4 front_color = texture(front_tex, UV);
	vec4 back_color = texture(back_tex, back_uv);

	ALBEDO = FRONT_FACING ? front_color.rgb : back_color.rgb;
	ALPHA = FRONT_FACING ? front_color.a : back_color.a;
}
