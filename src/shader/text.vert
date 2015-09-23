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
flat out uvec2 o_id;

#define CIRCLE            0
#define RECTANGLE         1
#define ROUNDED_RECTANGLE 2
#define DISTANCEFIELD     3

#define NEWLINE 10
#define SPACE 32

void main(){
	vec2  glyph_scale, bearing;
	int   index		  = gl_InstanceID;
    int   glyph 	  = int(texelFetch(glyphs, index).x);
    if(glyph == NEWLINE)
        glyph = SPACE; // This should probably be not done in the shader. But is for now, because I don't want to have the same glyphs in gpu memory as it is in the string
    glyph *= 2; // for lookups, there are two attributs in uvs for every glyph index
    vec4  attributes2 = texelFetch(uvs, glyph+1);
    
    if(shape == DISTANCEFIELD){
    	vec4  uv_dims   = texelFetch(uvs, glyph);
    	bearing 	    = attributes2.xy;
    	glyph_scale     = uv_dims.zw;
    	//flip uv and resize it to the correct size (for lookup in texture atlas)
    	o_uv 		    = (vec2(texturecoordinates.x, 1-texturecoordinates.y)*glyph_scale)+uv_dims.xy;
        glyph_scale    *= 4096;
    }else{ // special casing for particles
        bearing         = vec2(0.0, -8.0);
        glyph_scale     = attributes2.zw; //use advance instead of uv dimensions
        o_uv            = texturecoordinates*0.99 - 0.01; //texture coordinates need to be unscaled
    }
    uvec2  style_i      = texelFetch(style_index, index).xy;
    vec2  position	    = texelFetch(positions, index).xy;
    o_fill_color        = texelFetch(styles, int(style_i.x), 0);
    o_stroke_color      = vec4(1,1,1,1);
    o_glow_color 	    = vec4(0,0,0,1);
    o_id 			    = uvec2(objectid, index+1);
    gl_Position         = projectionview * model * vec4(position+bearing+(vertices*glyph_scale), 0, 1);
}