shader_type spatial;
render_mode cull_front, unshaded, depth_draw_always;

uniform vec4 outline_color : source_color = vec4(0.0, 0.8, 1.0, 0.5); // Couleur par défaut : cyan semi-transparent
uniform float outline_width : hint_range(0.0, 0.05) = 0.015; // Largeur du contour légèrement plus épaisse
uniform float glow_intensity : hint_range(0.0, 1.0) = 0.3; // Intensité de la lueur

void vertex() {
	vec4 clip_position = PROJECTION_MATRIX * (MODELVIEW_MATRIX * vec4(VERTEX, 1.0));
	vec3 clip_normal = mat3(PROJECTION_MATRIX) * (mat3(MODELVIEW_MATRIX) * NORMAL);

	// Calcul de l'offset pour le contour
	vec2 offset = normalize(clip_normal.xy) / VIEWPORT_SIZE * clip_position.w * outline_width * 2.0;

	clip_position.xy += offset;

	// Légère correction en profondeur pour éviter le z-fighting
	clip_position.z += 0.001 * clip_position.w;

	POSITION = clip_position;
}

void fragment() {
	// Couleur de base avec lueur
	vec3 final_color = outline_color.rgb * (1.0 + glow_intensity);

	ALBEDO = final_color;
	ALPHA = outline_color.a; // Opacité modérée pour un effet semi-transparent comme dans l'image
}