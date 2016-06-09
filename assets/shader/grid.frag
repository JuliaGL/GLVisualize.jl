{{GLSL_VERSION}}
uniform vec4 bg_color;
uniform vec4 grid_color;
uniform vec3 grid_thickness;
uniform vec3 gridsteps;

in vec3 vposition;

out vec4 fragment_color;
#define M_PI 3.1415926535897932384626433832795

#define ALIASING_CONST 0.70710678118654757

float aastep(float threshold1,float value) {
    float afwidth = length(vec2(dFdx(value), dFdy(value))) * ALIASING_CONST;
    return smoothstep(threshold1-afwidth, threshold1+afwidth, value);
}
vec3 aastep(vec3 threshold, vec3 value) {
	return vec3(aastep(threshold.x, value.x), aastep(threshold.y, value.y), aastep(threshold.z, value.z));
}

void write2framebuffer(vec4 color, uvec2 id);

void main()
{
 	vec3  v = (vec3(vposition.xyz) * gridsteps * M_PI) - 1.5;
    vec3  f = abs(sin(v));
    vec3  g = aastep(grid_thickness, f);
    float c = max(g.x, max(g.y, g.z));
    write2framebuffer(mix(bg_color, grid_color, c), uvec2(0));
}
