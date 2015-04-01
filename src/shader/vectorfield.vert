{{GLSL_VERSION}}
{{GLSL_EXTENSIONS}}

in vec3 vertex;
in vec3 normal; // normal might not be an uniform, whereas the other will be allways uniforms
in vec2 uv; // normal might not be an uniform, whereas the other will be allways uniforms

uniform vec3 cube_from; 
uniform vec3 cube_to; 
uniform vec2 color_range; 

uniform sampler3D vectorfield;
uniform sampler1D colormap;

uniform mat4 projection, view, model;

uniform vec3 light[4];
const int position = 3;

// data for fragment shader
out vec3 o_normal;
out vec3 o_lightdir;
out vec3 o_vertex;

void render(vec3 vertex, vec3 normal, vec2 uv,  mat4 model);
vec3 stretch(vec3 uvw, vec3 from, vec3 to);
mat4 rotation(vec3 direction);
void render(vec3 vertex, vec3 normal, mat4 model);


void main(){

    ivec3 cubesize    = textureSize(vectorfield, 0);
    ivec3 fieldindex  = ivec3(gl_InstanceID / (cubesize.y * cubesize.z), (gl_InstanceID / cubesize.z) % cubesize.y, gl_InstanceID % cubesize.z);
    vec3 uvw          = vec3(fieldindex) / vec3(cubesize);
    vec3 vectororigin = stretch(uvw, cube_from, cube_to);
    vec3 vector       = texelFetch(vectorfield, fieldindex, 0).xyz;
    float vlength     = length(vector);
    mat4 rotation_mat = rotation(vector);

    render(vertex, normal, model*getmodelmatrix(vectororigin, vec3(0.003, 0.003, 0.003))*rotation_mat, view, projection);
}