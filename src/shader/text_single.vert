{{GLSL_VERSION}}
{{GLSL_EXTENSIONS}}

in vec2 vertices;
in vec2 texturecoordinates;

uniform samplerBuffer positions;

uniform int offset;
uniform uint glyph;
uniform vec4 color;

uniform sampler2D uvs;
uniform mat4 projectionviewmodel;


out vec2 o_uv;
out vec4 o_color;

void main(){
	int   index		  = offset-1; //convert from julia indexes
    vec4  uv_dims  	  = texelFetch(uvs, ivec2(glyph, 0), 0);
    vec4  attributes2 = texelFetch(uvs, ivec2(glyph, 1), 0);
    
    vec2  bearing 	  = attributes2.xy;
    vec2  glyph_scale = uv_dims.zw;

    vec2  position	  = texelFetch(positions, index).xy-vec2(0,4);

    o_uv 			  = (vec2(texturecoordinates.x, 1-texturecoordinates.y)*uv_dims.zw)+uv_dims.xy;
    o_color 		  = color;
    gl_Position       = projectionviewmodel * vec4(position + (vertices*glyph_scale), 0, 1); 
}