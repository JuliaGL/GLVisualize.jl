{{GLSL_VERSION}}
{{GLSL_EXTENSIONS}}

in vec2 vertices;
in vec2 texturecoordinates;

uniform vec3 light[4];

uniform int technique;
uniform int style;
uniform uint objectid;

uniform vec2 position;
uniform vec2 scale;

uniform vec4 color;

uniform mat4 projectionview, model;

const int SPRITE = 1;
const int CIRCLE = 2;
const int SQUARE = 3;

out vec2 o_uv;
out vec4 o_color;

flat out int 	o_technique;
flat out int 	o_style;
flat out uvec2 	o_id;

void main(){
    o_uv              = texturecoordinates;
    o_color 		  = color;
    o_technique 	  = technique;
    o_style 		  = style;
    o_id 			  = uvec2(objectid, gl_VertexID+1);
    gl_Position       = projectionview * model * vec4(position + (vertices*scale), -50, 1); 

}
