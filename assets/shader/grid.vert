{{GLSL_VERSION}}

in vec3 vertices;

out vec3 vposition;

uniform mat4 projection, view, model;

void main()
{
    vec4 v   = model*vec4(vertices, 1.0);
    vposition = v.xyz;
    gl_Position = projection*view*v;
}
