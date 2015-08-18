{{GLSL_VERSION}}

in float       o_x;
in vec2        o_uv;
in vec4 	   o_color;

uniform sampler2D  images;

out vec4 	   fragment_color;

void main(){

	float 	alphaAbove	= texelFetch(images, ivec2(o_uv), 0).r;
	float 	textAlpha 	= alphaAbove * o_color.a;
	fragment_color 		= vec4(o_color.rgb, textAlpha);
}
