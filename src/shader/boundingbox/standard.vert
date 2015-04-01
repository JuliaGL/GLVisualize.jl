{{GLSL_VERSION}}

{{in}} vec3 vertex;
{{out}} vec4 V;
uniform mat4 model;
void main(){
	V = model*vec4(vertex,1);
   	gl_Position = vec4(0,0,0,1);
}