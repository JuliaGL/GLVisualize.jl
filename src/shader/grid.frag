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
void main()
{
 	vec3  v  		= (vec3(vposition.xyz) * gridsteps*10 * M_PI) - 1.5;
    vec3  f  		= abs(sin(v));
    vec3  g  		= aastep(vec3(0.999), f);
    float c  		= max(g.x, max(g.y, g.z));
    fragment_color 	= vec4(0.8,0.8,0.8, c);
}

