shader_type spatial;
// help from https://github.com/ColtonASimmons/GPU-Gems-Water-Caustics/
uniform float light_distance: hint_range(0.001, 1.0, 0.001) = 0.01;
uniform float water_height: hint_range(0.001, 1.0, 0.001) = 0.01;
uniform sampler2D ground;
uniform sampler2D light_map;

group_uniforms wave;
uniform int octaves: hint_range(0, 10, 1) = 2;
uniform float amplitude: hint_range(0.001, 1, 0.001) = 0.1;
uniform float frequency: hint_range(0.01, 0.1, 0.01) = 0.05;
uniform float factor: hint_range(0.01, 2.0, 0.01) = 1.0;
uniform float speed: hint_range(0.01, 5.0, 0.01) = 2.0;

varying vec3 world_pos;


vec2 grad_wave(float x, float y) {
	float dZx = 0.0;
	float dZy = 0.0;
	int oct = octaves;
	float fact = factor;
	float d = sqrt(x*x + y*y);

	do {
		dZx += d * sin(TIME * speed + (1.0 / fact) * x * y * frequency) * y * frequency
			- fact * cos(TIME * speed + (1.0 / fact) * x * y * frequency) * x / d;
		dZy += d * sin(TIME * speed + (1.0 / fact) * x * y * frequency) * x * frequency
			- fact * cos(TIME * speed + (1.0 / fact) * x * y * frequency) * y / d;
		fact = fact / 2.0;
		oct --;
	} while (oct > 0);

	return vec2(2.0 * amplitude * dZx, 2.0 * amplitude * dZy);
}

vec3 line_plane_intercept(vec3 origin, vec3 ray_dir, float plane_y) {

	float dist = (plane_y - ray_dir.y) / ray_dir.y;
	return origin + ray_dir * dist;
}

void vertex() {
	world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

void fragment() {
	vec2 dxdy = grad_wave(world_pos.x, world_pos.z);
	vec3 light_dir = normalize(vec3(-dxdy.x, -light_distance, -dxdy.y));
	vec3 intercept = line_plane_intercept(world_pos, light_dir, -water_height);
	
	vec3 colour = texture(ground, UV * 2.0).xyz * 0.3;
	colour += texture(light_map, intercept.xz * water_height).xyz;
	ALBEDO = colour;
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
