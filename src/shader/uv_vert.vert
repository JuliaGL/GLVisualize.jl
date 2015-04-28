{{GLSL_VERSION}}

in vec2 vertex;
in vec2 uv;

out vec2 uv_frag;

uniform mat4 projectionviewmodel;
void main(){
  uv_frag = uv;
  gl_Position = projectionviewmodel * vec4(vertex, 0, 1);
}