{{GLSL_VERSION}}

{{in}} vec3 vertexes;

{{out}} vec3 vposition;

uniform mat4 mvp;

void main()
{
    vposition   = vertexes;
    gl_Position = mvp * vec4(vertexes, 1.0);
}