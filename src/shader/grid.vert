{{GLSL_VERSION}}

in vec3 vertices;

out vec3 vposition;

uniform mat4 projection, view, model;

void main()
{
    vposition   = vertices;
    gl_Position = projection*view*model*vec4(vertices, 1.0);
}