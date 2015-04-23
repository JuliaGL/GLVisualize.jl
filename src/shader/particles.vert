{{GLSL_VERSION}}

in vec3 vertex;
in vec3 normal;

uniform vec3 light[4];
uniform vec4 particle_color;

uniform sampler2D positions;

uniform mat4 viewmodel, projection;

void render(vec3 vertex, vec3 normal, vec4 color, mat4 viewmodel, mat4 projection, vec3 light[4]);

vec4 getindex(sampler2D tex, int index);


void main(){
    vec3 vert = getindex(positions, gl_InstanceID).xyz + vertex;
    render(vert, normal, particle_color, viewmodel, projection, light);
    
}