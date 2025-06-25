shader_type canvas_item;

uniform sampler2D card_tex;
uniform vec4 rim_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform float rim_strength = 0.5;
uniform float rim_falloff = 6.0;

void fragment() {
	// Called for every pixel the material is visible on.
  vec4 base = texture(card_tex, UV);

  float dist_x = min(UV.x, 1.0 - UV.x);
  float dist_y = min(UV.y, 1.0 - UV.y);
  float edge_dist = min(dist_x, dist_y);

  float rim = pow(1.0 - edge_dist * 2.0, rim_falloff);
  rim = clamp(rim, 0.0, 1.0);

  COLOR = vec4(base.rgb + rim * rim_color.rgb * rim_strength, base.a);
}
