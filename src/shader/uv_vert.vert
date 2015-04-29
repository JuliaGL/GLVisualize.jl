{{GLSL_VERSION}}

in vec2 vertices;
in vec2 texturecoordinates;

out vec2 uv_frag;

uniform mat4 projectionviewmodel;
void main(){
  uv_frag = texturecoordinates;
  gl_Position = projectionviewmodel * vec4(vertices, 0, 1);
}