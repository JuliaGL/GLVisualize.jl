{{GLSL_VERSION}}

in vec2 o_uv;
out vec4 fragment_color;

{{image_type}} image;

void main(){
  vec4 texcolor   = texture(image, vec2(o_uv.x,1-o_uv.y));
	fragment_color  = texcolor.rgba;
}
 