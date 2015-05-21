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

out float o_x;
out vec2 o_uv;
out vec4 o_color;
out vec4 o_backgroundcolor;

void main(){
    uvec2 glyph 	  = getindex(glyphs, 	gl_InstanceID).xy;
    vec2 position	  = getindex(positions, gl_InstanceID).xy;
    vec4 attributes   = texelFetch(uvs, ivec2(glyph.x, gl_VertexID), 0);
    vec2 glyph_scale  = attributes.xy;
    o_x 			  = vertices.x;
    o_uv 			  = attributes.zw;
    o_color 		  = texelFetch(style, int(glyph.y), 0);
    o_backgroundcolor = vec4(0.0);
    gl_Position       = projectionviewmodel * vec4(position + (vertices*glyph_scale), 0, 1); 
}