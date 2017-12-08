{{GLSL_VERSION}}

layout(location=0) out vec4 fragment_color;
layout(location=1) out uvec2 fragment_groupid;


void write2framebuffer(vec4 color, uvec2 id){
    fragment_color = color;
    if(color.a <= 0.001) // for alpha cut outs
        discard;
    fragment_groupid = id;
}
