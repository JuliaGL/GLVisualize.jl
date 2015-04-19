{{GLSL_VERSION}}

in vec3 vertex;
in vec3 uvw;

out vec3 frag_verposition;

uniform mat4 projection, view;

void main()
{
    frag_verposition = vertex;
    gl_Position 	 = projection * view * vec4(vertex, 1);
}