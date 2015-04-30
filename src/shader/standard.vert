{{GLSL_VERSION}}

in vec3 vertices;
in vec3 normals;

uniform vec3 light[4];

uniform mat4 projection, viewmodel;

void render(vec3 vertices, vec3 normals, vec4 color, mat4 viewmodel, mat4 projection, vec3 light[4]);

void main()
{

	vec4 instance_color = vec4(1,0,0,1);
	render(vertices, normals, instance_color, viewmodel, projection, light);
}


