{{GLSL_VERSION}}
{{GLSL_EXTENSIONS}}

in vec2 vertices;
in vec2 texturecoordinates;

uniform vec3 light[4];
uniform vec2 scale;
uniform int technique;
uniform uint objectid;

uniform samplerBuffer positions;

{{color_type}} color;

uniform mat4 projectionview, model;

vec4 getindex(sampler2D tex, int index);
vec4 getindex(sampler1D tex, int index);

const int SPRITE = 1;
const int CIRCLE = 2;
const int SQUARE = 3;

out vec2 o_uv;
out vec4 o_color;

flat out int o_technique;
flat out int o_style;
flat out uvec2 o_id;
#define EPS32 0.000000119209289550781250
void main(){
	int   index		  = gl_InstanceID;
    o_uv              = texturecoordinates; 
   	vec2  position	  = texelFetch(positions, index).xy;
    o_color 		  = {{color_calculation}}
    o_technique 	  = technique;
    o_style 		  = 5;
    o_id 			  = uvec2(objectid, index+1);
    gl_Position       = projectionview * model * vec4(position + (vertices*scale), index*EPS32, 1);  //*EPS32 make sure to have slighty different Z for depth testing
    
}

