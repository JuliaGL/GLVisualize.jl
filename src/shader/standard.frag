{{GLSL_VERSION}}

in vec3 V;
in vec4 vert_color;

uniform vec3 light_position;

out vec4 fragment_color;
out uvec2 fragment_groupid;

vec4 blinnphong(vec3 N, vec3 V, vec3 L, vec3 light[4], vec4 mat[4]);


void main(){
    vec3 L      = normalize(light_position - V);
    vec3 light1 = blinnphong(N, V, L, vert_color.rgb);
    vec3 light2 = blinnphong(N, V, -L, vert_color.rgb);
    fragment_color      = vec4(light1 + light2, vert_color.a);
    fragment_groupid    = uvec2(0,0);
}
