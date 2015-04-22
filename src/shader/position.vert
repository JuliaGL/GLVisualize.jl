{{GLSL_VERSION}}
struct Rectangle
{
    vec2 origin;
    vec2 width;
};

in vec3 vertex;
in vec3 normal;

uniform vec3 light[4];
uniform sampler1D color_ramp;
uniform vec2 norm;

uniform sampler2D y_scale;

uniform vec2 grid_min;
uniform vec2 grid_max;

uniform mat4 viewmodel, projection;

void render(vec3 vertex, vec3 normal, vec4 color, mat4 viewmodel, mat4 projection, vec3 light[4]);

vec3 position(Rectangle rectangle, ivec2 dims, int index);
vec3 linear_texture(sampler2D tex, int index);
vec4 color(float intensity, sampler1D color_ramp, vec2 norm);


void main()
{
	vec3 pos 		= position(Rectangle(grid_min, grid_max), textureSize(y_scale, 0), gl_InstanceID);
	float intensity = linear_texture(y_scale, gl_InstanceID).x;
	pos += vertex;
	pos *= vec3(1, 1, intensity);

	vec4 instance_color = color(intensity, color_ramp, norm);
	render(pos, normal, instance_color, viewmodel, projection, light);
}


