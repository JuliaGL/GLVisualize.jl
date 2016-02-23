{{GLSL_VERSION}}

flat in vec4  o_color;
flat in uvec2 o_objectid;

out vec4 fragment_color;
out uvec2 fragment_groupid;

void main(){
    fragment_color   = o_color;
    fragment_groupid = o_objectid;
}
