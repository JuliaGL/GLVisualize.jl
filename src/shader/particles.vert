{{GLSL_VERSION}}
{{GLSL_EXTENSIONS}}
in vec3 vertices;
in vec3 normals;

uniform vec3 light[4];

{{color_type}} color;

uniform sampler2D positions;

uniform vec3 scale;
uniform mat4 viewmodel, projection;
void render(vec3 vertices, vec3 normals, vec4 color, mat4 viewmodel, mat4 projection, vec3 light[4]);

vec4 getindex(sampler2D tex, int index);


void main(){
	int index = gl_InstanceID;
    vec3 vert  = getindex(positions, index).xyz + (scale*vertices);

    vec4 c = {{color_calculation}};
    render(vert, normals, c, viewmodel, projection, light);
}