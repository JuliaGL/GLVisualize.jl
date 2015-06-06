{{GLSL_VERSION}}
{{GLSL_EXTENSIONS}}

in vec2 vertices;
in vec2 texturecoordinates;

uniform vec3 light[4];
uniform vec4 color;
uniform vec2 scale;

uniform sampler2D positions;

uniform mat4 projectionviewmodel;

vec4 getindex(sampler2D tex, int index);



out vec2 o_uv;
out vec4 o_color;
flat out int o_technique;
flat out int o_style;

void main(){
	int index 		= gl_InstanceID;
    vec2 vert 		= getindex(positions, index).xy + (vertices*scale);
    o_uv 			= texturecoordinates;
    o_technique 	= 2;
    o_style 		= 5;
    o_color 		= color;
    gl_Position     = projectionviewmodel * vec4(vert, 0.0, 1); 
}