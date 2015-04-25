{{GLSL_VERSION}}


in vec2 vertex;
in vec2 uv;

uniform uint objectid;

out vec2 frag_uv;
flat out uvec2 fragment_id;


uniform mat4 projectionviewmodel;

void main(){
	frag_uv 	= uv;
	fragment_id	= uvec2(objectid, 0);
   	gl_Position = projectionviewmodel * vec4(vertex, 0.0, 1.0);
}