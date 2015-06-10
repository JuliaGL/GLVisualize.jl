{{GLSL_VERSION}}
{{GLSL_EXTENSIONS}}

in vec2 vertices;
in vec2 texturecoordinates;

uniform vec3 light[4];
uniform vec2 scale;
uniform int technique;
uniform uint objectid;

uniform usamplerBuffer glyphs;
uniform samplerBuffer  positions;
uniform usamplerBuffer style_index;

uniform sampler2D uvs;
uniform sampler1D color;

uniform mat4 projectionviewmodel;

vec4 getindex(sampler2D tex, int index);

const int SPRITE = 1;
const int CIRCLE = 2;
const int SQUARE = 3;

out vec2 o_uv;
out vec4 o_color;

flat out int o_technique;
flat out int o_style;
flat out uvec2 o_id;

void main(){
	vec2 glyph_scale, bearing;
	int   index		  = gl_InstanceID;
	if(technique == SPRITE){
    	uint  glyph 	  = texelFetch(glyphs, index).x;
    	vec4  uv_dims  	  = texelFetch(uvs, ivec2(glyph, 0), 0);
    	vec4  attributes2 = texelFetch(uvs, ivec2(glyph, 1), 0);
    	
    	glyph_scale = attributes1.zw;
    	bearing 	= attributes2.xy;

    	uvec2  style_i    = texelFetch(style_index, index).xy;
    	o_uv 			  = (texturecoordinates*uv_dims.zw)+uv_dims.xy; //zw == width height, xy == xy
	}
	else{
		bearing 	= vec2(0.0);
		o_uv 		= texturecoordinates;
		glyph_scale = attributes2.zw;
	}

   	vec2  position	  = texelFetch(positions, index).xy;

    o_color 		  = texelFetch(color, int(style_i.x), 0);
    o_technique 	  = technique;
    o_style 		  = 5;
    o_id 			  = uvec2(objectid, index+1);
    gl_Position       = projectionviewmodel * vec4(position + bearing + (vertices*glyph_scale), 0, 1); 
    
}