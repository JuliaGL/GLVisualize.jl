{{GLSL_VERSION}}
{{GLSL_EXTENSIONS}}

in vec2 vertices;
in vec2 texturecoordinates;

uniform vec2 offset_scale;
uniform vec2 scale;

uniform int shape;
uniform int style;
uniform uint objectid;

uniform vec2 position;

uniform vec4 color;
uniform vec4 stroke_color;
uniform vec4 glow_color;

uniform mat4 projectionview, model;


flat out vec4 o_fill_color;
flat out vec4 o_stroke_color;
flat out vec4 o_glow_color;

flat out int o_shape;
flat out int o_style;
flat out uvec2 o_id;
out vec2 o_uv;

void main(){
	
	vec2 border 	  = offset_scale - scale;
	vec2 uv_size 	  = offset_scale / scale;
	vec2 border_rel   = border / offset_scale;
    o_uv              = (texturecoordinates*uv_size) - (border_rel*0.5); 

    o_fill_color 	  = color;
    o_stroke_color 	  = stroke_color;
    o_glow_color 	  = glow_color;

    o_shape 	  	  = shape;
    o_style 		  = style;
    o_id 			  = uvec2(objectid, gl_VertexID+1);
    gl_Position       = projectionview * model * vec4(position + (vertices*offset_scale), -50, 1); 

}
