{{GLSL_VERSION}}
uniform vec4 bg_color;
uniform vec4 grid_color;
uniform vec3 grid_thickness;
uniform vec3 gridsteps;

{{in}} vec3 vposition;

{{out}} vec4 fragment_color;
#define M_PI 3.1415926535897932384626433832795
void main()
{
 	vec3  v  		= vec3(vposition.xyz) * gridsteps * M_PI;
    vec3  f  		= abs(cos(v));
    vec3  df 		= fwidth(v);
    vec3  g  		= smoothstep(vec3(1.0) - vec3(0.01), vec3(1.0), f) * df;
    float c  		= max(g.x, max(g.y, g.z))*10;
    fragment_color 	= mix(bg_color, vec4(vposition, 0.2), c);
}