{{GLSL_VERSION}}

in vec3 vertex;

out vec4 o_color;

{{color_type}} color;
uniform mat4 projectionview, model;

void main()
{
	int index   = gl_VertexID;
	o_color 	= {{color_calculation}}
	gl_Position = projectionview*model * vec4(vertex, 1);
}