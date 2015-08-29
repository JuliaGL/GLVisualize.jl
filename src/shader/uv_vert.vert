{{GLSL_VERSION}}
{{GLSL_EXTENSIONS}}

in vec2 vertices;
in vec2 texturecoordinates;

out vec2 o_uv;

uniform mat4 projectionview, model;
void main(){
	o_uv = texturecoordinates;
	gl_Position = projectionview * model * vec4(vertices, 0, 1);
}
