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
out vec4 o_color;

void main(){
	int   index		  = offset-1; //convert from julia indexes
	int   glyph2 	  = int(glyph)*2;
    vec4  uv_dims  	  = texelFetch(uvs, glyph2);
    vec4  attributes2 = texelFetch(uvs, glyph2 + 1);
    
    vec2  bearing 	  = attributes2.xy;
    vec2  glyph_scale = uv_dims.zw;

    vec2  position	  = texelFetch(positions, index).xy-vec2(0,4); //hack hack, this is pretty much only to make the text cursor look good, while its only a '|'

    o_uv 			  = (vec2(texturecoordinates.x, 1-texturecoordinates.y)*uv_dims.zw)+uv_dims.xy;
    o_color 		  = color;
    gl_Position       = projectionview * model * vec4(position + (vertices*glyph_scale), 0, 1); 
}