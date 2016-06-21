{{GLSL_VERSION}}


layout(location=0) out vec4 opaque_color;
layout(location=1) out vec4 sum_color;
layout(location=2) out vec4 sum_weight;
layout(location=3) out uvec2 fragment_groupid;

uniform bool is_transparent_pass;


void write2framebuffer(vec4 color, uvec2 id){
    fragment_groupid = id;
    if(is_transparent_pass){
        // Assuming that the projection matrix is a perspective projection
        // gl_FragCoord.w returns the inverse of the oPos.w register from the vertex shader
        float viewDepth = abs(1.0 / gl_FragCoord.w);
        // Tuned to work well with FP16 accumulation buffers and 0.001 < linearDepth < 2.5
        // See Equation (9) from http://jcgt.org/published/0002/02/09/
        float linearDepth = viewDepth * 0.5;
        float weight = clamp(0.03 / (1e-5 + pow(linearDepth, 4.0)), 1e-2, 3e3);

        sum_color = vec4(color.rgb * color.a, color.a) * weight;
        sum_weight = vec4(color.a);

    }else{
        if(color.a < 0.99){
            discard;
        }
        opaque_color = color;
    }
}
