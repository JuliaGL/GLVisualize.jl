{{GLSL_VERSION}}
{{GLSL_EXTENSIONS}}

struct Nothing{ //Nothing type, to encode if some variable doesn't contain any data
    bool _; //empty structs are not allowed
};
struct Grid1D{
    float minimum;
    float maximum;
    int dims;
};
struct Grid2D{
    vec2 minimum;
    vec2 maximum;
    ivec2 dims;
};
struct Grid3D{
    vec3 minimum;
    vec3 maximum;
    ivec3 dims;
};

in vec3 vertices;
in vec3 normals;

uniform vec3 light[4];
uniform mat4 view, model, projection;
uniform uint objectid;


flat out uvec2 o_id;
     out vec4  o_color;

{{position_type}} position;
{{position_x_type}} position_x;
{{position_y_type}} position_y;
{{position_z_type}} position_z;
//Assembling functions for creating the right position from the above inputs. They also indicate the type combinations allowed for the above inputs
vec3 _position(samplerBuffer position, Nothing       position_x, float         position_y, float         position_z, int index);
vec3 _position(samplerBuffer position, Nothing       position_x, Nothing       position_y, float         position_z, int index);
vec3 _position(samplerBuffer position, Nothing       position_x, Nothing       position_y, Nothing       position_z, int index);
vec3 _position(Nothing       position, samplerBuffer position_x, samplerBuffer position_y, samplerBuffer position_z, int index);
vec3 _position(Grid1D        position, Nothing       position_x, Nothing       position_y, Nothing       position_z, int index);
vec3 _position(Grid2D        position, Nothing       position_x, Nothing       position_y, Nothing       position_z, int index);
vec3 _position(Grid3D        position, Nothing       position_x, Nothing       position_y, Nothing       position_z, int index);


{{scale_type}}   scale; // so in the case of distinct x,y,z, there's no chance to unify them under one variable
{{scale_x_type}} scale_x;
{{scale_y_type}} scale_y;
{{scale_z_type}} scale_z;

vec3 _scale(vec3          scale, Nothing scale_x, Nothing       scale_y, Nothing       scale_z, int index);
vec3 _scale(samplerBuffer scale, Nothing scale_x, Nothing       scale_y, Nothing       scale_z, int index);
vec3 _scale(vec3          scale, float   scale_x, samplerBuffer scale_y, float         scale_z, int index);
vec3 _scale(vec3          scale, float   scale_x, float         scale_y, samplerBuffer scale_z, int index);


{{rotation_type}}   rotation;
void rotate(Nothing       vectors, int index, in vec3 vertices, in vec3 normal);
void rotate(samplerBuffer vectors, int index, inout vec3 V, inout vec3 N);
void rotate(vec3          vectors, in vec3 vertices, in vec3 normal, int index);


{{color_type}}      color;
{{intensity_type}}  intensity;
{{color_norm_type}} color_norm;
vec4 _color(vec4          color, Nothing       intensity, Nothing color_norm, int index);
vec4 _color(samplerBuffer color, Nothing       intensity, Nothing color_norm, int index);
vec4 _color(sampler1D     color, samplerBuffer intensity, vec2    color_norm, int index);
float get_intensity(samplerBuffer rotation, int index){
    return length(texelFetch(rotation, index).xyz);
}
float get_intensity(Nothing rotation, int index){return 0.0;}

vec4 color_lookup(float intensity, sampler1D color_ramp, vec2 norm);
vec4 _color(sampler1D color, Nothing intensity, vec2 color_norm, int index){
    float _intensity = get_intensity(rotation, index);
    return color_lookup(_intensity, color, color_norm);
}

void render(vec3 vertices, vec3 normals, mat4 viewmodel, mat4 projection, vec3 light[4]);


void main(){
	int index = gl_InstanceID;
    o_id      = uvec2(objectid, index+1);
    vec3 V    = vertices;
    vec3 N    = normals;

	vec3 pos   = _position(position, position_x, position_y, position_z, index);
    vec3 scale = _scale(scale, scale_x, scale_y, scale_z, index);
    o_color    = _color(color, intensity, color_norm, index);

    V *= scale;
    rotate(rotation, index, V, N);
    render(pos + V, N, view*model, projection, light);
}
