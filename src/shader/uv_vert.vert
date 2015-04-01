{{GLSL_VERSION}}

{{in}} vec2 vertex;
{{in}} vec2 uv;

{{out}} vec2 uv_frag;

uniform mat4 projectionview, model;
void main(){
  uv_frag = uv;
  gl_Position = projectionview * model * vec4(vertex, 0, 1);
}