{{GLSL_VERSION}}
{{GLSL_EXTENSIONS}}
struct AABB
{
    vec3 min;
    vec3 max;
};

in vec3 vertices;
in vec3 normals;

uniform vec3 light[4];
uniform sampler3D vectorfield;
uniform sampler1D color;
uniform vec2 color_norm;

uniform vec3 cube_min;
uniform vec3 cube_max;

uniform mat4 view, model, projection;

void render(vec3 vertices, vec3 normals, vec4 color, mat4 viewmodel, mat4 projection, vec3 light[4]);

vec3 position(AABB cube, ivec3 dims, int index);
vec4 getindex(sampler3D tex, int index);
vec4 color_lookup(float intensity, sampler1D color_ramp, vec2 color_norm);
mat4 rotation(vec3 direction);
mat4 getmodelmatrix(vec3 xyz, vec3 scale);
mat4 rotationmatrix_y(float angle);


uniform uint objectid;
flat out uvec2 o_id;


void main()
{
	ivec3 dims 			= textureSize(vectorfield, 0);
	vec3 cell_size 		= (cube_max-cube_min)/vec3(dims);
    vec3 pos            = position(AABB(cube_min, cube_max), dims, gl_InstanceID);
    vec3 direction      = getindex(vectorfield, gl_InstanceID).xyz;
    mat4 rot            = rotation(direction);
    mat4 trans          = getmodelmatrix(pos+(cell_size/2.0), cell_size);
    float intensity     = length(direction);
    vec4 instance_color = color_lookup(intensity, color, color_norm);
    render(vertices, normals, instance_color, view*model*trans*rot, projection, light);
    o_id                = uvec2(objectid, gl_InstanceID);
}


