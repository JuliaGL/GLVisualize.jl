{{GLSL_VERSION}}
{{GLSL_EXTENSIONS}}
in vec3 vertices;
in vec3 normals;

uniform vec3 light[4];

{{particle_color_type}} particle_color;

uniform sampler2D positions;

uniform mat4 viewmodel, projection, model;

void render(vec3 vertices, vec3 normals, vec4 color, mat4 viewmodel, mat4 projection, vec3 light[4]);

vec4 getindex(sampler2D tex, int index);


void main(){
	int index = gl_InstanceID;
    vec3 vert  = getindex(positions, index).xyz + (model*vec4(vertices, 1)).xyz;

    vec4 color = {{particle_color_calculation}};
    render(vert, normals, color, viewmodel, projection, light);
}