{{GLSL_VERSION}}

vec3 hsv2rgb(vec3 c)
{
    vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

vec3 rgb2hsv(vec3 c)
{
    vec4 K = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
    vec4 p = c.g < c.b ? vec4(c.bg, K.wz) : vec4(c.gb, K.xy);
    vec4 q = c.r < p.x ? vec4(p.xyw, c.r) : vec4(c.r, p.yzx);
    float d = q.x - min(q.w, q.y);
    float e = 1.0e-10;
    return vec3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
}


in vec2 frag_uv;
flat in uvec2 fragment_id;

uniform vec4 color;


out uvec2 fragment_groupid;
out vec4 fragment_color;

float aastep(float threshold1, float threshold2,float value) {
    float afwidth = length(vec2(dFdx(value), dFdy(value))) * 0.70710678118654757;
    return smoothstep(threshold1-afwidth, threshold1+afwidth, value)-smoothstep(threshold2-afwidth, threshold2+afwidth, value);
}
vec4 radial_grad(float len, vec4 a, vec4 b) {
    return mix(a, b, len);
}  


void main(){
    float len     = frag_uv.y;
    float dist_aa = aastep(0.95, 0.99, len)+ aastep(0.95, 0.99, frag_uv.x);
    dist_aa       += aastep(0.01, 0.05, len)+ aastep(0.01, 0.05, frag_uv.x);
    dist_aa       -= aastep(0.00, 0.01, len)+ aastep(0.00, 0.01, frag_uv.x);
    dist_aa       -= aastep(0.99, 1.0, len)+ aastep(0.99, 1.0, frag_uv.x);
    vec4 radial     = radial_grad(length(frag_uv-0.5), color, vec4(0,0,1,1));
  	fragment_color = mix(vec4(0,0,0,0), radial, dist_aa);
}

