{{GLSL_VERSION}}

in vec3 o_normal;
in vec3 o_lightdir;
in vec3 o_vertex;
in vec4 o_color;
in vec2 o_uv;
flat in uvec2 o_id;

out vec4 fragment_color;
out uvec2 fragment_groupid;

const float ALIASING_CONST = 0.70710678118654757;

float aastep(float threshold1, float threshold2, float value) {
    float afwidth = length(vec2(dFdx(value), dFdy(value))) * ALIASING_CONST;
    return smoothstep(threshold1-afwidth, threshold1+afwidth, value)-smoothstep(threshold2-afwidth, threshold2+afwidth, value);
}

const float thickness = 0.01;
float square(vec2 uv)
{
    float xmin = aastep(-0.1, thickness, uv.x);
    float xmax = aastep(1.0-thickness, 1.01, uv.x);
    float ymin = aastep(-0.01, 0.0+thickness, uv.y);
    float ymax = aastep(1.0-thickness, 1.01, uv.y);
	return  xmin +
            xmax +
            ((1-xmin)*(1-xmax))*ymin +
            ((1-xmin)*(1-xmax))*ymax;
}

void main(){
    vec3 L      	= normalize(o_lightdir);
    vec3 N 			= normalize(o_normal);
    vec3 f_color    = mix(vec3(0,0,1), vec3(1), square(o_uv));
    vec3 light1 	= blinnphong(N, o_vertex, L, f_color);
    vec3 light2 	= blinnphong(N, o_vertex, -L,f_color);
    fragment_color 	= vec4(light1+light2*0.4, 1.0);
    if(fragment_color.a > 0.0)
        fragment_groupid = o_id;
}
