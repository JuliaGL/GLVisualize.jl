{{GLSL_VERSION}}
{{GLSL_EXTENSIONS}}

in vec2 vertices;
in vec2 texturecoordinates;

uniform usamplerBuffer glyphs;
uniform samplerBuffer positions;
uniform usamplerBuffer style_index;

uniform sampler2D uvs;
uniform sampler1D styles;

uniform int technique;
uniform uint objectid;

uniform mat4 projectionviewmodel;

out vec2 o_uv;
out vec4 o_color;

flat out int o_technique;
flat out int o_style;
flat out uvec2 o_id;

const int SPRITE = 1;
const int CIRCLE = 2;
const int SQUARE = 3;

void main(){
	vec2 glyph_scale, bearing;
	int   index		  = gl_InstanceID;
    uint  glyph 	  = texelFetch(glyphs, index).x;
    vec4  attributes2 = texelFetch(uvs, ivec2(glyph, 1), 0);
    
    if(technique == SPRITE){
    	vec4  uv_dims = texelFetch(uvs, ivec2(glyph, 0), 0);
    	bearing 	  = attributes2.xy;
    	glyph_scale   = uv_dims.zw;
    	//flip uv and resize it to the correct size (for lookup in texture atlas)
    	o_uv 		  = (vec2(texturecoordinates.x, 1-texturecoordinates.y)*uv_dims.zw)+uv_dims.xy;
    }else{ // special casing for particles.
    	bearing 	= vec2(0.0);
    	glyph_scale = attributes2.zw; //use advance instead of uv dimensions
    	o_uv 		= texturecoordinates; //texture coordinates need to be unscaled
    }
    uvec2  style_i    = texelFetch(style_index, index).xy;
    vec2  position	  = texelFetch(positions, index).xy;
    o_color 		  = texelFetch(styles, int(style_i.x), 0);
    o_style 		  = 5;
    o_id 			  = uvec2(objectid, index+1);
    o_technique 	  = technique;
    gl_Position       = projectionviewmodel * vec4(
    	position + bearing + (vertices*glyph_scale), 
    	0, 1
    ); 
}