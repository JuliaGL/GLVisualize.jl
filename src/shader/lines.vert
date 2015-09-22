{{GLSL_VERSION}}

in vec2 vertex;
in float lastlen;
//in float thickness;
uniform vec4 color;

uniform mat4 projectionview, model;
out vec4 g_color;
out float g_lastlen;
out float g_thickness;

void main()
{
	g_lastlen 	= lastlen;
	//g_thickness = thickness;
	g_color 	= color;
	gl_Position = projectionview*model*vec4(vertex, 0, 1);
}