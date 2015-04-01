{{GLSL_VERSION}}

{{out}} vec4 fragment_color;
{{in}} vec3 frag_uvw;

void main(){
   fragment_color = vec4(frag_uvw, 1.0);
}