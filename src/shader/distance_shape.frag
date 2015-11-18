{{GLSL_VERSION}}

#define CIRCLE            0
#define RECTANGLE         1
#define ROUNDED_RECTANGLE 2
#define DISTANCEFIELD     3
#define TRIANGLE          4

#define FILLED       1
#define OUTLINED     2
#define GLOWING      4
#define TEXTURE_FILL 8

#define ALIASING_CONST 0.70710678118654757

float aastep(float threshold1, float value) {
    float afwidth = length(vec2(dFdx(value), dFdy(value))) * ALIASING_CONST;
    return smoothstep(threshold1-afwidth, threshold1+afwidth, value);
}
float aastep(float threshold1, float threshold2, float value) {
    float afwidth = length(vec2(dFdx(value), dFdy(value))) * ALIASING_CONST;
    return smoothstep(threshold1-afwidth, threshold1+afwidth, value)-smoothstep(threshold2-afwidth, threshold2+afwidth, value);
}

#define M_SQRT_2 1.4142135
float triangle(vec2 P)
{
    P -= 0.5;
    float x = M_SQRT_2/2.0 * (P.x - P.y);
    float y = M_SQRT_2/2.0 * (P.x + P.y);
    float r1 = max(abs(x), abs(y)) - 1./(2*M_SQRT_2);
    float r2 = P.y;
    return -max(r1,r2);
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
    return -((length(max(vec2(0.0), d)) + min(0.0, max(d.x, d.y)))-tl.x);
}

uniform sampler2D distancefield;
uniform sampler2D texture_fill;

uniform float stroke_width;
uniform float glow_width;
uniform vec2 scale;


flat in vec4 o_fill_color;
flat in vec4 o_stroke_color;
flat in vec4 o_glow_color;

uniform int style; // style and shape are uniforms for now. Making them a varying && using them for control flow is expected to kill performance
uniform int shape;

in vec2 o_uv;
flat in uvec2 o_id;

out uvec2 fragment_groupid;
out vec4 fragment_color;

uniform vec2 resolution;
uniform bool transparent_picking;


void main(){

    float signed_distance = 0.0;
    vec4 fill_color, final_color = vec4(0.0);

    if(shape == CIRCLE)
    	signed_distance = circle(o_uv);
    else if(shape == DISTANCEFIELD){
        signed_distance = -texture(distancefield, o_uv).r;
    }
    else if(shape == ROUNDED_RECTANGLE)
    	signed_distance = rounded_rectangle(o_uv, vec2(0.2), vec2(0.8));
    else if(shape == RECTANGLE)
        signed_distance = rectangle(o_uv);
    else if(shape == TRIANGLE)
        signed_distance = triangle(o_uv);

    float half_stroke   = (stroke_width/2) / max(scale.x, scale.y);
    float inside        = aastep(0.0, 1.0, signed_distance);
    float outside       = abs(aastep(-1.0, 0.0, signed_distance));

    if(((style & TEXTURE_FILL) != 0) && inside > 0.0)
        fill_color = texture(texture_fill, vec2(o_uv.x, 1-o_uv.y));
    else
        fill_color = o_fill_color;

    if((style & (FILLED | TEXTURE_FILL)) != 0){
        final_color = mix(final_color, fill_color, inside);
    }
    if((style & OUTLINED) != 0){
        float t = aastep(0, half_stroke, signed_distance);
        final_color = mix(final_color, o_stroke_color, t);
    }
    if((style & GLOWING) != 0){
        float alpha = 1-(outside*abs(clamp(signed_distance, -1, 0))*7);
        alpha *= o_glow_color.a;
        final_color = mix(final_color, vec4(o_glow_color.rgb, alpha), outside);
    }
    fragment_color = final_color;
    if(transparent_picking || final_color.a >= 0.99999999)
        fragment_groupid = o_id;
}

