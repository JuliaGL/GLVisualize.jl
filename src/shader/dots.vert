{{GLSL_VERSION}}

in vec3 vertex;

out vec4 o_color;

{{color_type}} color;
uniform mat4 projectionviewmodel;

void main()
{
	int index   = gl_VertexID;
	o_color 	= {{color_calculation}}
	gl_Position = projectionviewmodel * vec4(vertex, 1);
}