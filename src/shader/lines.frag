{{GLSL_VERSION}}



in vec4 f_color;
in vec2 f_uv;
flat in uvec2 f_id;
uniform int shape;

const float ALIASING_CONST = 0.7710678118654757;

float aastep(float threshold1, float value) {
    float afwidth = length(vec2(dFdx(value), dFdy(value))) * ALIASING_CONST;
    return smoothstep(threshold1-afwidth, threshold1+afwidth, value);
}
float aastep(float threshold1, float threshold2, float value) {
    float afwidth = length(vec2(dFdx(value), dFdy(value))) * ALIASING_CONST;
    return smoothstep(threshold1-afwidth, threshold1+afwidth, value)-smoothstep(threshold2-afwidth, threshold2+afwidth, value);
}
float rectangle(vec2 uv)
{
    vec2 d = max(-uv, uv-vec2(1));
    return -((length(max(vec2(0.0), d)) + min(0.0, max(d.x, d.y))));
}
float circle(vec2 uv){
    return (1-length(uv-0.5))-0.5; 
}


out uvec2 fragment_groupid;
out vec4 fragment_color;

void main(){
	float signed_distance = rectangle(f_uv);
    float inside  = aastep(0.0, 120, signed_distance);
    fragment_color = vec4(f_color.rgb, f_color.a*inside);
    fragment_groupid = uvec2(0);
}

