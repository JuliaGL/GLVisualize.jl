{{GLSL_VERSION}}


{{in}} vec3 vertex;
{{in}} vec2 uv;

uniform uint objectid;

{{out}} vec2 frag_uv;
flat {{out}} uvec2 fragment_id;


uniform mat4 projection, view, model;

void main(){
	frag_uv 	= uv;
	fragment_id	= uvec2(objectid, 0);
   	gl_Position = projection * view * model * vec4(vertex, 1.0);
}