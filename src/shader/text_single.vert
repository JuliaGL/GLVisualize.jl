{{GLSL_VERSION}}
{{GLSL_EXTENSIONS}}

in vec2 vertices;

uniform samplerBuffer positions;

uniform uvec2 style_index;
uniform int offset;
uniform uint glyph;

uniform sampler2D uvs;
uniform sampler1D styles;

uniform mat4 projectionviewmodel;

uvec4 getindex(usampler2D tex, int index);
vec4 getindex(sampler2D tex, int index);

out vec2 o_uv;
out vec4 o_color;


vec2 getuv(vec4 attributes, int vertexid)
{
	if(vertexid == 1)
		return attributes.xy;
	if(vertexid == 0)
		return attributes.xw;
	if(vertexid == 3)
		return attributes.zw;
	if(vertexid == 2)
		return attributes.zy;

}
void main(){
	int   index		  = offset-1; //convert from julia indexes
    vec4  uv_dims  	  = texelFetch(uvs, ivec2(glyph, 0), 0);
    vec4  attributes2 = texelFetch(uvs, ivec2(glyph, 1), 0);
    
    vec2  bearing 	  = attributes2.xy;
    vec2  glyph_scale = attributes2.zw;

    vec2  position	  = texelFetch(positions, index).xy-vec2(0,4);

    o_uv 			  = getuv(uv_dims, gl_VertexID);
    o_color 		  = texelFetch(styles, int(style_index.x), 0);
    gl_Position       = projectionviewmodel * vec4(position + (vertices*glyph_scale), 0, 1); 
}