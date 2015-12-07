{{GLSL_VERSION}}
{{GLSL_EXTENSIONS}}

struct Nothing{ //Nothing type, to encode if some variable doesn't contain any data
    bool _; //empty structs are not allowed
};


{{uv_offset_width_type}} uv_offset_width;
//{{uv_x_type}} uv_width;
{{position_type}} position;
Nothing position_x;
Nothing position_y;
Nothing position_z;

{{scale_type}} scale; // so in the case of distinct x,y,z, there's no chance to unify them under one variable
Nothing scale_x;
Nothing scale_y;
Nothing scale_z;

{{rotation_type}}   rotation;

{{color_type}}        color;
{{stroke_color_type}} stroke_color;
{{glow_color_type}}   glow_color;
{{intensity_type}}    intensity;
{{color_norm_type}}   color_norm;

uniform mat4 model;
uniform uint objectid;

flat out uvec2 g_id;

out int  g_primitive_index;
out vec3 g_position;
out vec2 g_scale;

out vec4 g_color;
out vec4 g_stroke_color;
out vec4 g_glow_color;

out vec4 g_uv_offset_width;

vec3 _rotation(Nothing rotation){return vec3(0);}
vec2 _scale(float scale){return vec2(scale);}
vec2 _scale(vec2 scale){return scale;}
vec2 _scale(vec3 scale){return vec2(scale);}

vec3 _position(vec3 p){return p;}
vec3 _position(vec2 p){return vec3(p, 0);}
mat4 getmodelmatrix(vec3 xyz, vec3 scale);

void main(){
	g_primitive_index = gl_VertexID;
    g_position        = _position(position);
    g_uv_offset_width = uv_offset_width;
    g_id              = uvec2(objectid, gl_VertexID);
    g_color           = color;
    g_stroke_color    = stroke_color;
    g_glow_color      = glow_color;
    g_scale           = _scale(scale);
}
