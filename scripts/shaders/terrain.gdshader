shader_type spatial;
render_mode world_vertex_coords;

uniform float angle_threshold;
uniform vec3 grass_color : source_color;
uniform vec3 rock_color : source_color;

varying float vertical_angle;
varying vec3 global_normal;

void vertex() {
	global_normal = NORMAL;
	vertical_angle = global_normal.y;
}

void fragment() {
	ALBEDO = vertical_angle > angle_threshold ? rock_color : grass_color;
	//ALBEDO = vec3(1.0, 1.0, vertical_angle);
}

//void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
//}
