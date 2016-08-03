{{GLSL_VERSION}}

in vec3 vertices;
in vec3 texturecoordinates;

out vec3 frag_vertposition;

uniform mat4 projection, view, model;


void main()
{
    frag_vertposition = texturecoordinates;
    gl_Position 	  = projection * view * model * vec4(vertices, 1);
}
