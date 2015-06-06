{{GLSL_VERSION}}
{{GLSL_EXTENSIONS}}

in vec2 vertices;

uniform usampler2D glyphs;
uniform sampler2D positions;
uniform sampler2D uvs;
uniform sampler1D style;

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
	int   index		  = gl_InstanceID;
    uvec2 glyph 	  = getindex(glyphs, 	index).xy;
    vec4  uv_dims  	  = texelFetch(uvs, ivec2(glyph.x, 0), 0);
    vec4  attributes2 = texelFetch(uvs, ivec2(glyph.x, 1), 0);
    
    vec2  bearing 	  = attributes2.xy;
    vec2  glyph_scale = attributes2.zw;

    vec2  position	  = getindex(positions, index).xy+bearing;

    o_uv 			  = getuv(uv_dims, gl_VertexID);
    o_color 		  = texelFetch(style, int(glyph.y), 0);
    gl_Position       = projectionviewmodel * vec4(position + (vertices*glyph_scale), 0, 1); 
}