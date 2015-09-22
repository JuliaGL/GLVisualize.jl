{{GLSL_VERSION}}
{{GLSL_EXTENSIONS}}

in vec2 vertices;
in vec2 texturecoordinates;

uniform usamplerBuffer glyphs;
uniform samplerBuffer  positions;
uniform usamplerBuffer style_index;

uniform samplerBuffer uvs;
uniform sampler1D styles;

uniform int shape;
uniform uint objectid;

uniform mat4 projectionview, model;
uniform mat4 fixed_projectionview;
uniform vec2 resolution;

out vec2 o_uv;

flat out vec4 o_fill_color;
flat out vec4 o_stroke_color;
flat out vec4 o_glow_color;

flat out int o_shape;
flat out int o_style;
flat out uvec2 o_id;

const int CIRCLE = 0;
const int SQUARE = 1;
const int DISTANCEFIELD = 2;

const int NEWLINE = 10;
const int SPACE   = 32;

void main(){
	vec2  glyph_scale, bearing;
	int   index		  = gl_InstanceID;
    int   glyph 	  = int(texelFetch(glyphs, index).x);
    if(glyph == NEWLINE)
        glyph = SPACE; // This should probably be not done in the shader...
    glyph *= 2; // for lookups, there are two attributs in uvs for every glyph index
    vec4  attributes2 = texelFetch(uvs, glyph+1);
    
    if(true){
    	vec4  uv_dims = texelFetch(uvs, glyph);
    	bearing 	  = attributes2.xy;
    	glyph_scale   = uv_dims.zw;
    	//flip uv and resize it to the correct size (for lookup in texture atlas)
    	o_uv 		  = ((vec2(texturecoordinates.x, 1-texturecoordinates.y)*uv_dims.zw)+uv_dims.xy);
    }else{ // special casing for particles
        bearing     = vec2(0.0, -6.0);
        glyph_scale = attributes2.zw; //use advance instead of uv dimensions
        o_uv        = texturecoordinates; //texture coordinates need to be unscaled
    }
    uvec2  style_i    = texelFetch(style_index, index).xy;
    vec2  position	  = texelFetch(positions, index).xy;
    o_fill_color      = texelFetch(styles, int(style_i.x), 0);
    o_stroke_color    = vec4(1,1,1,1);
    o_glow_color 	  = vec4(0,0,0,1);

    o_style 		  = 1;
    o_id 			  = uvec2(objectid, index+1);
    o_shape 	      = shape;
    gl_Position       = projectionview * model * vec4(position+vertices*(glyph_scale*4096), 0, 1);
}