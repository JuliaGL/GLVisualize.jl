{{GLSL_VERSION}}

in vec2 o_uv;
out vec4 fragment_color;

{{intensity_type}} intensity;
uniform sampler1D color;
uniform vec2 color_norm;

vec4 getindex(sampler2D image, vec2 uv){return texture(image, uv);}
vec4 getindex(sampler1D image, vec2 uv){return texture(image, uv.y);}
float _normalize(float val, float from, float to){return (val-from) / (to - from);}

vec4 color_lookup(float intensity, sampler1D color_ramp, vec2 norm){
    return texture(color_ramp, _normalize(intensity, norm.x, norm.y));
}
#define ALIASING_CONST 0.70710678118654757
#define M_PI 3.1415926535897932384626433832795
float aastep(float threshold1, float threshold2, float value) {
    float afwidth = length(vec2(dFdx(value), dFdy(value))) * ALIASING_CONST;
    return smoothstep(threshold1-afwidth, threshold1+afwidth, value)-smoothstep(threshold2-afwidth, threshold2+afwidth, value);
}
void main(){
	float i = float(getindex(intensity, o_uv).x);
	vec4 stroke_color = vec4(1,1,1,1);
	float lines = i*10*M_PI;
	lines = abs(sin(lines));
	lines = aastep(0.5, 0.6, lines);

	fragment_color  = mix(color_lookup(i, color, color_norm), stroke_color, lines);
}
 