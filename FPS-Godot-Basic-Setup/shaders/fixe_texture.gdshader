shader_type spatial;

uniform sampler2D albedo_texture : source_color;
uniform float uv_shrink : hint_range(0.0, 0.01) = 0.002;

void fragment() {
    vec2 shrink_uv = UV * (1.0 - 2.0 * uv_shrink) + uv_shrink;
    vec4 color = textureLod(albedo_texture, shrink_uv, 0.0);
    ALBEDO = color.rgb;
    ALPHA = color.a;
}
