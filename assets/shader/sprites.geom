{{GLSL_VERSION}}
{{GLSL_EXTENSIONS}}

layout(points) in;
layout(triangle_strip, max_vertices = 4) out;

uniform bool billboard;
uniform float stroke_width;
uniform float glow_width;
uniform vec2 resolution;

in int  g_primitive_index[];
in vec4 g_uv_offset_width[];
in vec4 g_color[];
in vec4 g_stroke_color[];
in vec4 g_glow_color[];
in vec3 g_position[];
in vec3 g_rotation[];
in vec4 g_offset_width[];
in uvec2 g_id[];

flat out int  f_primitive_index;
flat out vec2 f_scale;
flat out vec4 f_color;
flat out vec4 f_stroke_color;
flat out vec4 f_glow_color;
flat out uvec2 f_id;
out vec2 f_uv;
out vec2 f_uv_offset;

const vec3 UP_VECTOR = vec3(0,0,1);
mat3 rotation_mat(vec3 direction){
    direction = normalize(direction);
    mat3 rot = mat3(1.0);
    if(direction == UP_VECTOR)
        return rot;
    vec3 xaxis = normalize(cross(UP_VECTOR, direction));

    vec3 yaxis = normalize(cross(direction, xaxis));

    rot[0][0] = xaxis.x;
    rot[1][0] = yaxis.x;
    rot[2][0] = direction.x;

    rot[0][1] = xaxis.y;
    rot[1][1] = yaxis.y;
    rot[2][1] = direction.y;

    rot[0][2] = xaxis.z;
    rot[1][2] = yaxis.z;
    rot[2][2] = direction.z;

    return rot;
}

uniform mat4 projection, view, model;
/*
vec4 _position(vec2 position, Nothing heightfield, int index){
    return vec4(position, 0, 1);
}
vec4 _position(vec2 position, sampler2D heightfield, int index){
    float z = linear_texture(z, index, vertices).x;
    return vec4(position, z, 1);
}
*/

void emit_vertex(vec2 vertex, vec2 uv, vec2 uv_offset)
{
    vec4 final_position = model*vec4(g_position[0], 1);

    if(billboard){
        final_position = projection*view*final_position;
        gl_Position    = final_position + (projection*vec4(vertex, 0, 0));
    }else{
        mat3 rot       = rotation_mat(g_rotation[0]);
        final_position = final_position+vec4(rot*vec3(vertex, 0), 0);
        gl_Position    = projection*view*final_position;
    }

    f_uv              = uv;
    f_uv_offset       = uv_offset;
    f_primitive_index = g_primitive_index[0];
    f_color           = g_color[0];
    f_stroke_color    = g_stroke_color[0];
    f_glow_color      = g_glow_color[0];
    f_scale           = g_offset_width[0].zw;
    f_id              = g_id[0];

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
    vec4 o_w = g_offset_width[0];
    vec4 uv_o_w = g_uv_offset_width[0];
    vec4 vertices = vec4(0, 0, 1, 1); // use offset as origin quad (x,y,w,h)
    float glow_stroke = glow_width+stroke_width;
    vec4 uv_min_max = vec4(0,0,1,1); //minx, miny, maxx, maxy

    vertices.xy *= o_w.zw+glow_stroke; // scale
    vertices.zw *= o_w.zw+glow_stroke;
    vertices.xy += o_w.xy; // offset
    vertices.zw += o_w.xy;

    emit_vertex(vertices.xy, uv_min_max.xw, uv_o_w.xw);
    emit_vertex(vertices.xw, uv_min_max.xy, uv_o_w.xy);
    emit_vertex(vertices.zy, uv_min_max.zw, uv_o_w.zw);
    emit_vertex(vertices.zw, uv_min_max.zy, uv_o_w.zy);
    EndPrimitive();
}
