{{GLSL_VERSION}}
{{GLSL_EXTENSIONS}}

in vec2 vertices;
in vec2 uv;

uniform vec3 light[4];
uniform vec4 particle_color;

uniform sampler2D positions;

uniform mat4 viewmodel, projection, model;

void render(vec3 vertices, vec3 normals, vec4 color, mat4 viewmodel, mat4 projection, vec3 light[4]);

vec4 getindex(sampler2D tex, int index);


void main(){
    vec3 vert = getindex(positions, gl_InstanceID).xy + (model*vec4(vertices, 1)).xy;
    render(vert, vec3(0,1,0), particle_color, viewmodel, projection, light);
}