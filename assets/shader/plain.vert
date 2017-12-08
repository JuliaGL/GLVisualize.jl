{{GLSL_VERSION}}
{{GLSL_EXTENSIONS}}

{{vertices_type}} vertices;
{{vertex_color_type}} vertex_color;

uniform mat4 projection, view, model;
uniform uint objectid;
{{color_type}} color;

flat out uvec2 o_objectid;
out vec4 o_color;

vec4 _position(vec3 p){return vec4(p,1);}
vec4 _position(vec2 p){return vec4(p,0,1);}

vec4 _color(Nothing vcolor, vec3 color){return vec4(color, 1);}
vec4 _color(vec3 vcolor, Nothing color){return vec4(vcolor, 1);}

vec4 _color(Nothing vcolor, vec4 color){return color;}
vec4 _color(vec4 vcolor, Nothing color){return vcolor;}

void main(){
    o_objectid  = uvec2(objectid, gl_VertexID + 1);
    o_color = _color(vertex_color, color);
    gl_Position = projection * view * model * _position(vertices);

}
