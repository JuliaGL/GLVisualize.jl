{{GLSL_VERSION}}
{{GLSL_EXTENSIONS}}

struct Nothing{ //Nothing type, to encode if some variable doesn't contain any data
    bool _; //empty structs are not allowed
};
struct Grid1D{
    float minimum;
    float maximum;
    int dims;
    float multiplicator;
};
struct Grid2D{
    vec2 minimum;
    vec2 maximum;
    ivec2 dims;
    vec2 multiplicator;

};
struct Grid3D{
    vec3 minimum;
    vec3 maximum;
    ivec3 dims;
    vec3 multiplicator;
};

in vec3 vertices;
in vec3 normals;

uniform vec3 light[4];
uniform mat4 view, model, projection;
uniform uint objectid;
uniform int len;

flat out uvec2 o_id;
     out vec4  o_color;


{{position_type}} position;
{{position_x_type}} position_x;
{{position_y_type}} position_y;
{{position_z_type}} position_z;

ivec2 ind2sub(ivec2 dim, int linearindex);
ivec3 ind2sub(ivec3 dim, int linearindex);


{{rotation_type}}   rotation;
void rotate(Nothing       vectors, int index, inout vec3 vertices, inout vec3 normal);
void rotate(samplerBuffer vectors, int index, inout vec3 V, inout vec3 N);
void rotate(vec3          vectors, int index, inout vec3 vertices, inout vec3 normal);



{{scale_type}}   scale; // so in the case of distinct x,y,z, there's no chance to unify them under one variable
{{scale_x_type}} scale_x;
{{scale_y_type}} scale_y;
{{scale_z_type}} scale_z;
vec3 get_rotation(samplerBuffer rotation, int index){
    return texelFetch(rotation, index).xyz;
}
vec3 get_rotation(Nothing rotation, int index){
    return vec3(0,0,1);
}
vec3 get_rotation(vec3 rotation, int index){
    return rotation;
}
vec3 _scale(samplerBuffer scale, Nothing scale_x, Nothing       scale_y, Nothing       scale_z, int index);
vec3 _scale(vec3          scale, float   scale_x, samplerBuffer scale_y, float         scale_z, int index);
vec3 _scale(vec3          scale, float   scale_x, float         scale_y, samplerBuffer scale_z, int index);
vec3 _scale(Nothing       scale, float   scale_x, float         scale_y, samplerBuffer scale_z, int index);

vec3 _scale(Nothing       scale, float   scale_x, float         scale_y, Nothing scale_z, int index){
    vec3 rot = get_rotation(rotation, index);
    return vec3(scale_x,scale_y, length(rot));
}
vec3 _scale(vec2 scale, Nothing scale_x, Nothing scale_y, Nothing scale_z, int index);
vec3 _scale(vec3 scale, Nothing scale_x, Nothing scale_y, Nothing scale_z, int index){
    vec3 rot = get_rotation(rotation, index);
    return vec3(scale.xy, scale.z*length(rot));
}



{{color_type}}      color;
{{color_map_type}}  color_map;
{{intensity_type}}  intensity;
{{color_norm_type}} color_norm;
// constant color!
vec4 _color(vec4 color, Nothing intensity, Nothing color_map, Nothing color_norm, int index, int len);
// only a samplerBuffer, this means we have a color per particle
vec4 _color(samplerBuffer color, Nothing intensity, Nothing color_map, Nothing color_norm, int index, int len);
// no color, but intensities a color map and color norm. Color will be based on intensity!
vec4 _color(Nothing color, sampler1D intensity, sampler1D color_map, vec2 color_norm, int index, int len);
vec4 _color(Nothing color, samplerBuffer intensity, sampler1D color_map, vec2 color_norm, int index, int len);
// no color, no intensities a color map and color norm. Color will be based on z_position or rotation!
vec4 _color(Nothing color, Nothing intensity, sampler1D color_map, vec2 color_norm, int index, int len);

float get_intensity(samplerBuffer rotation, Nothing position_z, int index){
    return length(texelFetch(rotation, index).xyz);
}
float get_intensity(vec3 rotation, Nothing position_z, int index){return length(rotation);}
float get_intensity(Nothing rotation, Nothing position_z, int index){return -1.0;}
float get_intensity(Nothing rotation, samplerBuffer position_z, int index){
    return texelFetch(position_z, index).x;
}
float get_intensity(vec3 rotation, samplerBuffer position_z, int index){
    return texelFetch(position_z, index).x;
}
vec4 color_lookup(float intensity, sampler1D color_ramp, vec2 norm);

vec4 _color(Nothing color, Nothing intensity, sampler1D color_map, vec2 color_norm, int index, int len){
    float _intensity = get_intensity(rotation, scale_z, index);
    return color_lookup(_intensity, color_map, color_norm);
}

void render(vec3 vertices, vec3 normals, mat4 viewmodel, mat4 projection, vec3 light[4]);



void main(){
	int index = gl_InstanceID;
    o_id      = uvec2(objectid, index+1);
    vec3 V    = vertices;
    vec3 N    = normals;
    vec3 pos;
	{{position_calc}}
    vec3 scale = _scale(scale, scale_x, scale_y, scale_z, index);
    o_color    = _color(color, intensity, color_map, color_norm, index, len);
    V *= scale;
    rotate(rotation, index, V, N);
    render(pos + V, N, view*model, projection, light);
}
