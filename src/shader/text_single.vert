{{GLSL_VERSION}}
{{GLSL_EXTENSIONS}}

in vec2 vertices;
in vec2 texturecoordinates;

uniform samplerBuffer positions;

uniform int offset;
uniform uint glyph;
uniform vec4 color;

uniform samplerBuffer uvs;
uniform mat4 projectionview, model;


out vec2 o_uv;

flat out vec4 o_fill_color;
flat out vec4 o_stroke_color;
flat out vec4 o_glow_color;
flat out uvec2 o_id;

void main(){
	int   index		  = offset-1; //convert from julia indexes
	int   glyph2 	  = int(glyph)*2;
    vec4  uv_dims  	  = texelFetch(uvs, glyph2);
    vec4  attributes2 = texelFetch(uvs, glyph2 + 1);
    
    vec2  bearing 	  = attributes2.xy;
    vec2  glyph_scale = uv_dims.zw;

    vec2  position	  = texelFetch(positions, index).xy-vec2(0,4); //hack hack, this is pretty much only to make the text cursor look good, while its only a '|'

    o_uv 			  = (vec2(texturecoordinates.x, 1-texturecoordinates.y)*glyph_scale)+uv_dims.xy;
    o_fill_color 	  = color;
    o_stroke_color    = vec4(1,1,1,1);
    o_glow_color      = vec4(0,0,0,1);
    gl_Position       = projectionview * model * vec4(position + (vertices*(glyph_scale*4096)), 0, 1); 
}