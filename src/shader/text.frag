{{GLSL_VERSION}}

in float       o_x;
in vec2        o_uv;
in vec4 	   o_color;
in vec4 	   o_backgroundcolor;

//flat in uvec2  o_objectid;

uniform sampler2D  images;

out vec4 	   fragment_color;
//out uvec2 	   fragment_groupid;

void main(){

	float 	alphaAbove	= texelFetch(images, ivec2(o_uv), 0).r;
	fragment_color 		= vec4(o_color.rgb, alphaAbove);
	/*if (o_x > 0.5) // move boundaries for text selection to the middle of the glyp
		fragment_groupid 	= o_objectid;
	else
		fragment_groupid 	= o_objectid - uvec2(0,1);*/
}	