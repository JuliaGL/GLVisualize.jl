{{GLSL_VERSION}}
{{in}} vec3 vertex;
{{out}} vec3 V;

uniform mat4 model;

void main()
{
	V = vec3(model * vec4(vertex, 1.0));
    gl_Position = vec4(0,0,0,1);
}