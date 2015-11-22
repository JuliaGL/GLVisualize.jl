{{GLSL_VERSION}}
{{GLSL_EXTENSIONS}}

struct Nothing{ //Nothing type, to encode if some variable doesn't contain any data
    bool _; //empty structs are not allowed
};

uniform vec3 light[4];

{{uv_x_type}} uv_offset_width;
{{uv_x_type}} uv_width;
{{position_type}} position;
Nothing position_x;
Nothing position_y;
Nothing position_z;

{{scale_type}} scale; // so in the case of distinct x,y,z, there's no chance to unify them under one variable
Nothing scale_x;
Nothing scale_y;
Nothing scale_z;

{{rotation_type}}   rotation;

{{color_type}}      color;
{{intensity_type}}  intensity;
{{color_norm_type}} color_norm;

uniform mat4 model;
uniform uint objectid;

flat out uvec2 g_id;

out vec4 g_color;
out vec4 g_uv_offset_width;
out mat4 g_model;

void main(){
    int index = gl_VertexID;
    g_model = model*translationmatrix(
        _position(position, position_x, position_y, position_z, index),
        _scale(scale, scale_x, scale_y, scale_z),
        _rotation(rotation)
    );
    g_uv_offset_width    = uv_offset_width;
    g_id    = uvec2(objectid, index);
    g_color = colorize(color, intensity, color_norm);
}