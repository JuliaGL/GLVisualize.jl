{{GLSL_VERSION}}
{{GLSL_EXTENSIONS}}

in vec2 vertices;
in vec2 texturecoordinates;
uniform samplerBuffer positions;

uniform vec2 offset_scale;
uniform vec2 scale;
uniform int shape;
uniform int style;
uniform uint objectid;


{{color_type}} color;
{{stroke_color_type}} stroke_color;
{{glow_color_type}} glow_color;

uniform mat4 projectionview, model;

out vec2 o_uv;

flat out vec4 o_fill_color;
flat out vec4 o_stroke_color;
flat out vec4 o_glow_color;

flat out int o_shape;
flat out int o_style;
flat out uvec2 o_id;

#define EPS32 0.000000119209289550781250


vec4 getindex(sampler2D tex, int index);
vec4 getindex(sampler1D tex, int index);

void main(){
	int   index		  = gl_InstanceID;
	vec2 border 	  = offset_scale - scale;
	vec2 uv_size 	  = offset_scale / scale;
	vec2 border_rel   = border / offset_scale;
    o_uv              = (texturecoordinates*uv_size) - (border_rel*0.5); 
   	vec2  position	  = texelFetch(positions, index).xy;
    
    o_shape 	  	  = shape;
    o_style 		  = style;

    o_fill_color 	  = {{color_calculation}}
    o_stroke_color 	  = {{stroke_color_calculation}}
    o_glow_color 	  = {{glow_color_calculation}}

    o_id 			  = uvec2(objectid, index+1);
    gl_Position       = projectionview * model * vec4(position + (vertices*offset_scale), index*EPS32, 1);  //*EPS32 make sure to have slighty different Z for depth testing
}

