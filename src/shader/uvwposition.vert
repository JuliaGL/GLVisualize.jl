{{GLSL_VERSION}}

{{in}} vec3 vertex;
{{in}} vec3 uvw;
{{out}} vec3 frag_uvw;
uniform mat4 projectionview;

void main(){
   frag_uvw = uvw;
   gl_Position = projectionview * vec4(vertex, 1.0);
}