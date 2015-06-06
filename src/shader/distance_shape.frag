{{GLSL_VERSION}}

in vec4 o_color;
in vec2 o_uv;
flat in int o_technique;
flat in int o_style;


out vec4 fragment_color;

uniform sampler2D images;
uniform float thickness;

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
	float len = length(uv-0.5);
	if(o_style==FILLED)
		return aastep(0.5, len);
	if(o_style==OUTLINED)
		return aastep(0.5, 0.5-thickness, len);
}

void main(){
    float alpha = 0;
    if(o_technique == SPRITE)
    	alpha = texelFetch(images, ivec2(o_uv), 0).r;
    if(o_technique == CIRCLE)
    	alpha = circle(o_uv);
    if(o_technique == SQUARE)
    	alpha = square(o_uv);

    fragment_color = vec4(o_color.rgb, o_color.a*alpha);
}
