{{GLSL_VERSION}}

in vec4 o_color;
in vec2 o_uv;

out vec4 fragment_color;

float aastep(float threshold1, float threshold2,float value) {
    float afwidth = length(vec2(dFdx(value), dFdy(value))) * 0.70710678118654757;
    return smoothstep(threshold1-afwidth, threshold1+afwidth, value)-smoothstep(threshold2-afwidth, threshold2+afwidth, value);
}

float aastep(float threshold1,float value) {
    float afwidth = length(vec2(dFdx(value), dFdy(value))) * 0.70710678118654757;
    return smoothstep(threshold1-afwidth, threshold1+afwidth, value);
}
vec4 radial_grad(float len, vec4 a, vec4 b) {
    return mix(a, b, len);
}  

void main(){
    float len      = length(o_uv-0.5);
    float dist_aa  = aastep(0.5, len);
    fragment_color = vec4(o_uv,0.1,0.0);
}
