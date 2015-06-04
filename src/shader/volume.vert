{{GLSL_VERSION}}

in vec3 vertices;
in vec3 texturecoordinates;

out vec3 frag_vertposition;

uniform mat4 projection_view_model;

void main()
{
    frag_vertposition = texturecoordinates;
    gl_Position 	  = projection_view_model * vec4(vertices, 1);
}