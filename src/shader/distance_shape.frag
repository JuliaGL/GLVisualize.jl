{{GLSL_VERSION}}

in vec4 o_color;
in vec2 o_uv;

flat in int o_technique;
flat in int o_style;
flat in uvec2 o_id;


uniform vec2        scale;
uniform sampler2D   images;
uniform float       thickness = 4.0;

const int SPRITE = 1;
const int CIRCLE = 2;
const int SQUARE = 3;

const int OUTLINED = 4;
const int FILLED = 5;

const float ALIASING_CONST = 0.70710678118654757;

float aastep(float threshold1, float threshold2, float value) {
    float afwidth = length(vec2(dFdx(value), dFdy(value))) * ALIASING_CONST;
    return smoothstep(threshold1-afwidth, threshold1+afwidth, value)-smoothstep(threshold2-afwidth, threshold2+afwidth, value);
}

float aastep(float threshold1,float value) {
    float afwidth = length(vec2(dFdx(value), dFdy(value))) * ALIASING_CONST;
    return smoothstep(threshold1-afwidth, threshold1+afwidth, value);
}
vec4 radial_grad(float len, vec4 a, vec4 b) {
    return mix(a, b, len);
}  

float circle(vec2 uv)
{
	float len = 1-length(uv-0.5);
	if(o_style==FILLED)
		return aastep(0.5, len);
	if(o_style==OUTLINED)
		return aastep(0.5, 0.5-thickness, len);
}
float square(vec2 uv)
{
    float edge = 0.0;
	if(o_style==FILLED)
		return (uv.x*0.0)+1; //silly way of using uv, which otherwise would be removed by the unused code elimination
	if(o_style==OUTLINED)
    {
        float xmin = aastep(0.0, 0.0+thickness/scale.x, uv.x);
        float xmax = aastep(1.0-thickness/scale.x, 1.0, uv.x);
        float ymin = aastep(0.0, 0.0+thickness/scale.y, uv.y);
        float ymax = aastep(1.0-thickness/scale.y, 1.0, uv.y);
		return  xmin +
                xmax +
                ((1-xmin)*(1-xmax))*ymin +
                ((1-xmin)*(1-xmax))*ymax;
    }
}

out uvec2 fragment_groupid;
out vec4 fragment_color;

void main(){
    float alpha = 0;
    if(o_technique == SPRITE)
    	alpha = texelFetch(images, ivec2(o_uv), 0).r;
    if(o_technique == CIRCLE)
    	alpha = circle(o_uv);
    if(o_technique == SQUARE)
    	alpha = square(o_uv);
    alpha *= o_color.a;
    fragment_color = vec4(o_color.rgb, alpha);
    fragment_groupid = o_id;
}
