{{GLSL_VERSION}}
{{GLSL_EXTENSIONS}}
in vec3 vertices;
in vec3 normals;

uniform vec3 light[4];

{{color_type}} color;

uniform samplerBuffer positions;

uniform vec3 scale;
uniform mat4 view, model, projection;
void render(vec3 vertices, vec3 normals, vec4 color, mat4 viewmodel, mat4 projection, vec3 light[4]);

vec4 getindex(sampler2D tex, int index);
vec4 getindex(sampler1D tex, int index);


uniform uint objectid;
flat out uvec2 o_id;

void main(){
	int index = gl_InstanceID;
    vec3 vert = texelFetch(positions, index).xyz + (scale*vertices);
    vec4 c 	  = {{color_calculation}}
    render(vert, normals, c, view*model, projection, light);
    o_id      = uvec2(objectid, index);
}