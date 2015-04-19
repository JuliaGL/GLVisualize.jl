{{GLSL_VERSION}}

in vec3 vertex;
in vec3 uvw;

out vec3 frag_verposition;

uniform mat4 projection_view_model;

void main()
{
    frag_verposition = vertex;
    gl_Position 	 = projection_view_model * vec4(vertex, 1);
}