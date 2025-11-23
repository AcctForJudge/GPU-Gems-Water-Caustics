shader_type spatial;
// code from https://developer.nvidia.com/gpugems/gpugems/part-i-natural-effects/chapter-2-rendering-water-caustics
group_uniforms non_wave;
uniform vec3 colour: source_color = vec3(0.2, 0.6, 0.8);
uniform float transparency: hint_range(0.0, 1.0, 0.01) = 0.6;
uniform float mettalic: hint_range(0.0, 1.0, 0.01) = 0.0;
uniform float roughness: hint_range(0.0, 1.0, 0.01) = 0.2;
uniform float specular: hint_range(0.0, 1.0, 0.01) = 0.5;

group_uniforms wave;
uniform int octaves: hint_range(0, 10, 1) = 2;
uniform float amplitude: hint_range(0.001, 1, 0.001) = 0.1;
uniform float frequency: hint_range(0.01, 0.1, 0.01) = 0.05;
uniform float factor: hint_range(0.01, 2.0, 0.01) = 1.0;
uniform float speed: hint_range(0.01, 5.0, 0.01) = 2.0;

varying vec3 world_pos;

// here, height (y axis in godot) is the z axis
float wave(float x, float y) {
	float height = 0.0;
	int oct = octaves;
	float fact = factor;
	float d = sqrt(x*x + y*y);

	do {
		height -= fact * cos(speed * TIME + (1.0 / fact) * x * y * frequency);
		fact = fact / 2.0;
		oct--;
	} while (oct > 0);
	return 2.0 * amplitude * d * height;
}

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



void vertex() {
	world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	VERTEX.y = wave(world_pos.x, world_pos.z);

	vec2 n = grad_wave(world_pos.x, world_pos.z);
	vec3 n_m = normalize(vec3(-n.x, 1.0, -n.y));
	NORMAL = n_m;
}


void fragment() {

    ALBEDO = colour;
	//ALBEDO = colour;
	METALLIC = mettalic;
	ROUGHNESS = roughness;
	SPECULAR = specular;
	ALPHA = transparency;
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
