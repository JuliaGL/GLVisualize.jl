{{GLSL_VERSION}}
{{GLSL_EXTENSIONS}}

in vec2 vertices;

uniform sampler2D glyphs;
uniform sampler2D uvs;
uniform sampler2D style;

uniform mat4 projectionviewmodel;

vec4 getindex(sampler2D tex, int index);


out vec2 o_uv;
out vec4 o_color;

void main(){
    vec4 glyph 		 = getindex(glyphs, gl_InstanceID);
    vec4 attributes  = getindex(uvs, vec2(glyph.z, gl_VertexID));
    vec2 glyph_scale = attributes.xy;
    o_uv 			 = attributes.zw;
    o_color 		 = getindex(style, glyph.w);
    gl_Position      = projectionviewmodel * vec4(glyph.xy + (vertices*glyph_scale), 0, 1); 
}