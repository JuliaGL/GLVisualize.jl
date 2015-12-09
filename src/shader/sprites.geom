{{GLSL_VERSION}}
{{GLSL_EXTENSIONS}}

layout(points) in;
layout(triangle_strip, max_vertices = 4) out;

in int  g_primitive_index[];
in vec4 g_uv_offset_width[];
in vec4 g_color[];
in vec4 g_stroke_color[];
in vec4 g_glow_color[];
in vec3 g_position[];
in vec2 g_scale[];
in uvec2 g_id[];

flat out int  f_primitive_index;
flat out vec2 f_scale;
flat out vec4 f_color;
flat out vec4 f_stroke_color;
flat out vec4 f_glow_color;
flat out uvec2 f_id;
out vec2 f_uv;


uniform mat4 projectionview, model;
/*
vec4 _position(vec2 position, Nothing heightfield, int index){
    return vec4(position, 0, 1);
}
vec4 _position(vec2 position, sampler2D heightfield, int index){
    float z = linear_texture(z, index, vertices).x;
    return vec4(position, z, 1);
}
*/

void emit_vertex(vec2 vert, vec2 uv)
{
    vec4 final_position = vec4(g_position[0]+vec3(vert*g_scale[0], 0), 1);
    f_uv              = uv;
    f_primitive_index = g_primitive_index[0];
    f_color           = g_color[0];
    f_stroke_color    = g_stroke_color[0];
    f_glow_color      = g_glow_color[0];
    f_scale           = g_scale[0];
    f_id              = g_id[0];
    gl_Position       = projectionview*model*final_position;
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
    emit_vertex(vec2(0,0), g_uv_offset_width[0].xw);
    emit_vertex(vec2(0,1), g_uv_offset_width[0].xy);
    emit_vertex(vec2(1,0), g_uv_offset_width[0].zw);
    emit_vertex(vec2(1,1), g_uv_offset_width[0].zy);
    EndPrimitive();
}
