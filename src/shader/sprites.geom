{{GLSL_VERSION}}

layout(points) in;
layout(triangle_strip, max_vertices = 4) out;

in vec4 g_uv_offset_width[];
in vec4 g_color[];
flat in uvec2 g_id[];
in mat4 g_model[];


out vec4 f_color;
out vec4 f_stroke_color;
out vec2 f_uv;
flat out uvec2 f_id;

uniform mat4 projectionview;
uniform sampler2D heightfield;

vec4 _position(vec2 position, Nothing heightfield, int index){
    return vec4(position, 0, 1);
}
vec4 _position(vec2 position, sampler2D heightfield, int index){
    float z = linear_texture(z, index, vertices).x;
    return vec4(position, z, 1);
}

void emit_vertex(vec2 position, vec2 uv)
{
    vec4 final_position = _position(position, heightfield, gl_VertexID);
    f_uv          = uv;
    f_color       = g_color[0];
    f_id          = g_id[0];
    gl_Position   = projectionview*g_model[0]*final_position;

    EmitVertex();
}


void main(void)
{
    // emit quad as triangle strip
    // v3. ____ . v4
    //    |\   |
    //    | \  |
    //    |  \ |
    //    |___\|
    // v1*      * v2
    emit_vertex(vec2(0,0), g_uv_offset_width[0].xy);
    emit_vertex(vec2(1,0), g_uv_offset_width[0].wy);
    emit_vertex(vec2(0,1), g_uv_offset_width[0].xz);
    emit_vertex(vec2(1,1), g_uv_offset_width[0].zw);
    EndPrimitive();
  
}



