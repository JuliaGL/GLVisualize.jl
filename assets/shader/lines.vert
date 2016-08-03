{{GLSL_VERSION}}
{{GLSL_EXTENSIONS}}

{{vertex_type}} vertex;
in float lastlen;
{{color_type}} color;

uniform mat4 projection, view, model;
uniform uint objectid;
uniform ivec2 dims;

out uvec2 g_id;
out vec4 g_color;
out float g_lastlen;
out uint g_line_connections;

vec4 getindex(sampler2D tex, int index);
vec4 getindex(sampler1D tex, int index);

vec4 to_vec4(vec3 v){return vec4(v, 1);}
vec4 to_vec4(vec2 v){return vec4(v, 0, 1);}


void main()
{
    g_lastlen = lastlen;
    int index = gl_VertexID;
    g_id = uvec2(objectid, index+1);
    g_color = {{color_calculation}};
    g_line_connections = uint(index/dims.x);
    gl_Position = projection*view*model*to_vec4(vertex);
}
