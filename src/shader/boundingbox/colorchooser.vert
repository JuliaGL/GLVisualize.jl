{{GLSL_VERSION}}


{{in}} vec3 vertex;
{{in}} vec2 uv;

{{out}} vec2 frag_uv;
{{out}} vec4 V;


uniform mat4 projection, view, model;

void main(){
	frag_uv 	= uv;
	V 			= model * vec4(vertex, 1.0);
   	gl_Position = vec4(0,0,0,1);
}