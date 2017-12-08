{{GLSL_VERSION}}

flat in uvec2 o_id;

in vec4 o_color;



void write2framebuffer(vec4 color, uvec2 id);

void main(){
    write2framebuffer(o_color, o_id);
}
