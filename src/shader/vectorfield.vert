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
uniform sampler1D color_ramp;
uniform vec2 norm;

uniform vec3 cube_min;
uniform vec3 cube_max;

uniform mat4 view, model, projection;

void render(vec3 vertices, vec3 normals, vec4 color, mat4 viewmodel, mat4 projection, vec3 light[4]);

vec3 position(AABB cube, ivec3 dims, int index);
vec4 getindex(sampler3D tex, int index);
vec4 color(float intensity, sampler1D color_ramp, vec2 norm);
mat4 rotation(vec3 direction);
mat4 getmodelmatrix(vec3 xyz, vec3 scale);

void main()
{
    vec3 pos            = position(AABB(cube_min, cube_max), textureSize(vectorfield, 0), gl_InstanceID);
    vec3 direction      = vec3(1,1,1);
    mat4 rot            = rotation(direction);
    mat4 trans          = getmodelmatrix(pos, vec3(0.1));
    float intensity     = length(direction);
    vec4 instance_color = vec4(direction, 1);
    render((rot*vec4(vertices, 1)).xyz, normals, instance_color, view*trans, projection, light);
}


