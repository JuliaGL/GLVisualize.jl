{{GLSL_VERSION}}

in vec2 o_uv;
out vec4 fragment_color;

{{image_type}} image;

vec4 getindex(sampler2D image, vec2 uv)
{
	return texture(image, vec2(uv.x,1-uv.y));
}
vec4 getindex(sampler1D image, vec2 uv)
{
	return texture(image, uv.y);
}
void main(){
	fragment_color  = getindex(image, o_uv);
}
 