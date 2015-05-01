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
mat4 rotationmatrix_y(float angle);




void main()
{
    vec3 pos            = position(AABB(cube_min, cube_max), textureSize(vectorfield, 0), gl_InstanceID);
    vec3 direction      = getindex(vectorfield, gl_InstanceID).xyz;
    mat4 rot            = rotation(direction);
    mat4 trans          = getmodelmatrix(pos, vec3(1.0));
    mat4 scl          	= getmodelmatrix(vec3(0), vec3(0.1));
    float intensity     = length(direction);
    vec4 instance_color = color(intensity, color_ramp, norm);
    render(vertices*vec3(0.5, 0.5, 0.3), normals, instance_color, view*trans*rot, projection, light);
}


