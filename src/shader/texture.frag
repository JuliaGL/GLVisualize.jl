{{GLSL_VERSION}}

in vec2 uv_frag;
out vec4 fragment_color;

{{image_type}} image;

void main(){
  vec4 texcolor = texture(image, vec2(uv_frag.x,1-uv_frag.y));
	fragment_color = vec4(texcolor.rgb,1.0);
}
 