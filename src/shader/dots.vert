{{GLSL_VERSION}}

in vec3 vertex;

out vec4 o_color;

uniform sampler1D particle_color;
uniform mat4 projectionviewmodel;

void main()
{
	o_color 	= texture(particle_color, float(gl_VertexID)/float(textureSize(particle_color, 0)));
	gl_Position = projectionviewmodel * vec4(vertex, 1);
}