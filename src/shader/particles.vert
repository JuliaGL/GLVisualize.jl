{{GLSL_VERSION}}
{{GLSL_EXTENSIONS}}

in vec3 vertices;
in vec3 normals;

uniform vec3 light[4];
struct Nothing{ //Nothing type, to encode if some variable doesn't contain any data
    bool _; //empty structs are not allowed
}
const nothing = Nothing(false);

{{position_type}} position; 
{{position_x_type}} position_x; 
{{position_y_type}} position_y;
{{position_z_type}} position_z;

{{scale_type}} scale; // so in the case of distinct x,y,z, there's no chance to unify them under one variable
{{scale_x_type}} scale_x; // this is awkward, but hard to do differently because you can't put samplers in a struct,
{{scale_y_type}} scale_y;
{{scale_z_type}} scale_z;

{{rotation_type}}   rotation;
{{color_type}}      color;
{{color_norm_type}} color_norm;

uniform mat4 view, model, projection;
void render(vec3 vertices, vec3 normals, vec4 color, mat4 viewmodel, mat4 projection, vec3 light[4]);

vec4 getindex(sampler2D tex, int index);
vec4 getindex(sampler1D tex, int index);

uniform uint objectid;
flat out uvec2 o_id;

void rotate(Nothing r, in vec3 vertices, in vec3 normal, int index){} // no-op
void rotate(samplerBuffer quaternions, in vec3 vertices, in vec3 normal, int index){} 
{
    vec4 q = texelFetch(quaternions, index);
}
void rotate(vec3 direction, in vec3 vertices, in vec3 normal){} 
{
    
}

void colorize(vec4 color, int index, Nothing intensity, Nothing color_norm)
{
    o_color = color;
}
void colorize(samplerBuffer color, int index, Nothing intensity, Nothing color_norm)
{
    o_color = texelFetch(color, index, 0);
}
void colorize(sampler2D color, int index, samplerBuffer intensity, vec2 color_norm)
{
    o_color = color_lookup(texelFetch(intensity, index), color, color_norm);
}
vec3 position(samplerBuffer position, Nothing position_x, Nothing position_y, Nothing position_z, int index)
{
    return texelFetch(position, index).xyz;
}
vec3 position(Nothing position, samplerBuffer position_x, samplerBuffer position_y, samplerBuffer position_z, int index)
{
    return vec3(
        texelFetch(position_x, index),
        texelFetch(position_y, index),
        texelFetch(position_z, index),
    );
}
vec3 position(AABB cube, Nothing position_x, Nothing position_y, Nothing position_z, int index)
{
    return position(cube, grid_dimensions, index);
}
vec3 position(Rectangle rect, Nothing position_x, Nothing position_y, Nothing position_z, int index)
{
    return position(rect, grid_dimensions, index);
}
void main(){
	int index = gl_InstanceID;
	vec3 pos  = position(position, position_x, position_y, position_z, index);

    rotate(rotation, vertices, normals);
    scale(scale, scale_x, scale_y, scale_z, vertices);
    colorize(color, index, intensity, color_norm);

    o_id = uvec2(objectid, index);
    render(pos + vertices, normals, view*model, projection, light);
}