{{GLSL_VERSION}}


#define CIRCLE            0
#define RECTANGLE         1
#define ROUNDED_RECTANGLE 2
#define DISTANCEFIELD     3

in vec4 f_color;
in vec2 f_uv;
flat in uvec2 f_id;
uniform int shape;
uniform bool dotted;

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
float rounded_rectangle(vec2 uv, vec2 tl, vec2 br)
{
    vec2 d = max(tl-uv, uv-br);
    return -((length(max(vec2(0.0), d)) + min(0.0, max(d.x, d.y)))-tl.x);
}

out uvec2 fragment_groupid;
out vec4 fragment_color;

void main(){
    if(dotted){
        vec2 uv = vec2(fract(f_uv.x), f_uv.y); 
        float signed_distance;
        if(shape == CIRCLE)
            signed_distance = circle(uv);
        else if(shape == ROUNDED_RECTANGLE)
            signed_distance = rounded_rectangle(uv, vec2(0.2), vec2(0.8));
        else if(shape == RECTANGLE)
            signed_distance = rectangle(uv);
        float inside     = aastep(0.01, 120.0, signed_distance);
        fragment_color   = vec4(f_color.rgb, f_color.a*inside);
    }else{
        fragment_color   = vec4(f_color.rgb, aastep(0.1, 0.9, f_uv.y));
    }
    fragment_groupid = f_id;
}

