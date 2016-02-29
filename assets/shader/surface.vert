{{GLSL_VERSION}}
{{GLSL_EXTENSIONS}}

struct Grid2D{
    vec2 minimum;
    vec2 maximum;
    ivec2 dims;
    vec2 multiplicator;

};

struct Nothing{ //Nothing type, to encode if some variable doesn't contain any data
    bool _; //empty structs are not allowed
} nothing;

in vec2 vertices;

{{position_type}} position;
{{position_x_type}} position_x;
{{position_y_type}} position_y;
uniform sampler2D position_z;

uniform vec3 light[4];
{{color_type}} color;
{{color_map_type}} color_map;
{{color_norm_type}} color_norm;

vec4 color_lookup(float intensity, sampler1D color, vec2 norm);
// constant color!
vec4 get_color(vec4 color, float _intensity, Nothing color_map, Nothing color_norm, int index){
    return color;
}

vec4 get_color(Nothing color, float _intensity, sampler1D color_map, vec2 color_norm, int index){
    return color_lookup(_intensity, color_map, color_norm);
}

uniform vec3 scale;

uniform mat4 view, model, projection;

void render(vec3 vertices, vec3 normal, mat4 viewmodel, mat4 projection, vec3 light[4]);
ivec2 ind2sub(ivec2 dim, int linearindex);
vec2 linear_index(ivec2 dims, int index, vec2 offset);
vec4 linear_texture(sampler2D tex, int index, vec2 offset);
vec3 getnormal(sampler2D zvalues, vec2 uv);

uniform uint objectid;
flat out uvec2 o_id;
out vec4 o_color;




void main()
{
    int index       = gl_InstanceID;
	ivec2 dims 		= textureSize(position_z, 0);
    vec2 offset     = vertices;
	vec3 pos;
    {{position_calc}}
	pos           += vec3(scale.xy*vertices, 0.0);
	o_color        = get_color(color, pos.z, color_map, color_norm, index);
	vec3 normalvec = getnormal(position_z, linear_index(dims, index, vertices));
    o_id           = uvec2(objectid, index+1);
	render(pos, normalvec, view*model, projection, light);
}
