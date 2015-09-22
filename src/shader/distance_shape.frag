{{GLSL_VERSION}}

const float ALIASING_CONST = 0.70710678118654757;

float aastep(float threshold1, float value) {
    float afwidth = length(vec2(dFdx(value), dFdy(value))) * ALIASING_CONST;
    return smoothstep(threshold1-afwidth, threshold1+afwidth, value);
}
float aastep(float threshold1, float threshold2, float value) {
    float afwidth = length(vec2(dFdx(value), dFdy(value))) * ALIASING_CONST;
    return smoothstep(threshold1-afwidth, threshold1+afwidth, value)-smoothstep(threshold2-afwidth, threshold2+afwidth, value);
}

float circle(vec2 uv){ 
    return (1-length(uv-0.5))-0.5; 
}
float rectangle(vec2 uv)
{
    vec2 d = max(-uv, uv-vec2(1));
    return -((length(max(vec2(0.0), d)) + min(0.0, max(d.x, d.y))));
}
float rounded_rectangle(vec2 uv, vec2 tl, vec2 br)
{
    vec2 d = max(tl-uv, uv-br);
    return -((length(max(vec2(0.0), d)) + min(0.0, max(d.x, d.y)))-tl);
}

uniform sampler2D distancefield;
uniform sampler2D texture_fill;

uniform float stroke_width;
uniform float glow_width;
uniform vec2 scale;


#define CIRCLE            0
#define RECTANGLE         1
#define ROUNDED_RECTANGLE 2
#define DISTANCEFIELD     3

#define FILLED       1
#define OUTLINED     2
#define GLOWING      4
#define TEXTURE_FILL 8


flat in vec4 o_fill_color;
flat in vec4 o_stroke_color;
flat in vec4 o_glow_color;

flat in int o_style;
flat in int o_shape;

in vec2 o_uv;
flat in uvec2 o_id;

out uvec2 fragment_groupid;
out vec4 fragment_color;

uniform vec2 resolution;
uniform bool transparent_picking;


void main(){

    float signed_distance = 0.0;
    
    signed_distance = texture(distancefield, o_uv).r;
    if(o_shape == CIRCLE)
    	signed_distance = circle(o_uv);
    else if(o_shape == ROUNDED_RECTANGLE)
    	signed_distance = rounded_rectangle(o_uv, vec2(0.2), vec2(0.8));
    else if(o_shape == RECTANGLE)
        signed_distance = rectangle(o_uv);

    float half_stroke = (stroke_width/2) / max(scale.x, scale.y);
    
    vec4 color = vec4(0);
    float inside  = aastep(0.0, 1.0, signed_distance);
    float outside = abs(aastep(-1.0, 0.0, signed_distance));
    vec4 fcolor;

    if((o_style & TEXTURE_FILL) != 0 && inside > 0.0)
        fcolor = texture(texture_fill, vec2(o_uv.x, 1-o_uv.y));
    else
        fcolor = o_fill_color;

    if(((o_style & FILLED) != 0 || (o_style & TEXTURE_FILL) != 0)){
        color = mix(color, fcolor, inside);
    }
    if((o_style & OUTLINED) != 0){
        float t = aastep(0, half_stroke, signed_distance);
        color = mix(color, o_stroke_color, t);
    }
    if((o_style & GLOWING) != 0 ){
        float alpha = 1-(outside*abs(clamp(signed_distance, -1, 0))*7);
        alpha *= o_glow_color.a;
        color = mix(color, vec4(o_glow_color.rgb, alpha), outside);
    }
    fragment_color = color;
    if(true || color.a >= 0.99999999)
        fragment_groupid = o_id;
}

