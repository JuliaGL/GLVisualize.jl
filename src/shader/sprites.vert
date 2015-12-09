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
//Assembling functions for creating the right position from the above inputs. They also indicate the type combinations allowed for the above inputs
vec3 _position(Grid1D position, Nothing position_x, Nothing position_y, Nothing position_z, int index);
vec3 _position(Grid2D position, Nothing position_x, Nothing position_y, Nothing position_z, int index);
vec3 _position(Grid3D position, Nothing position_x, Nothing position_y, Nothing position_z, int index);
vec3 _position(vec2   position, Nothing position_x, Nothing position_y, Nothing position_z, int index);
vec3 _position(vec3   position, Nothing position_x, Nothing position_y, Nothing position_z, int index);


{{scale_type}} scale; // so in the case of distinct x,y,z, there's no chance to unify them under one variable
Nothing scale_x;
Nothing scale_y;
Nothing scale_z;
void _scale(Nothing scale, Nothing scale_x, Nothing scale_y, Nothing scale_z, int index);
void _scale(vec3    scale, Nothing scale_x, Nothing scale_y, Nothing scale_z, int index);
void _scale(Nothing scale, float   scale_x, float   scale_y, float   scale_z, int index);

{{rotation_type}}     rotation;

{{color_type}}        color;
{{intensity_type}}    intensity;
{{color_norm_type}}   color_norm;
vec4 _color(vec4      color, Nothing intensity, Nothing color_norm, int index);
vec4 _color(sampler1D color, float   intensity, vec2    color_norm, int index);


{{stroke_color_type}} stroke_color;
{{glow_color_type}}   glow_color;

uniform uint objectid;

out uvec2 g_id;
out int   g_primitive_index;
out vec3  g_position;
out vec2  g_scale;
out vec4  g_color;
out vec4  g_stroke_color;
out vec4  g_glow_color;
out vec4  g_uv_offset_width;


void main(){
	g_primitive_index = gl_VertexID;
    g_position        = _position(position, scale_x, scale_y, scale_z, 0);
    g_scale           = _scale(scale, scale_x, scale_y, scale_z, 0).xy;
    g_color           = _color(color, intensity, color_norm, 0);

    g_uv_offset_width = uv_offset_width;
    g_stroke_color    = stroke_color;
    g_glow_color      = glow_color;
    g_id              = uvec2(objectid, gl_VertexID+1);
}
