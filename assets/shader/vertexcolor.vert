{{GLSL_VERSION}}

in vec3 vertices;
in vec3 normals;
in vec4 color;

uniform vec3 light[4];

uniform mat4 projection, view, model;

void render(vec3 vertices, vec3 normals, mat4 viewmodel, mat4 projection, vec3 light[4]);

uniform uint objectid;

out vec4 o_color;
flat out uvec2 o_id;

void main()
{
	o_id = uvec2(objectid, 0);
	o_color = color;
	render(vertices, normals, view*model, projection, light);
}
