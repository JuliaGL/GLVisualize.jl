{{GLSL_VERSION}}
{{GLSL_EXTENSIONS}}

in vec2 vertices;
in vec2 texturecoordinates;

uniform vec3 light[4];
uniform vec4 color;
uniform vec2 scale;
uniform float technique;
uniform uint objectid;

uniform samplerBuffer positions;

uniform mat4 projectionviewmodel;

vec4 getindex(sampler2D tex, int index);



out vec2 o_uv;
out vec4 o_color;
flat out int o_technique;
flat out int o_style;
flat out uvec2 o_id;

void main(){
	int index 		= gl_InstanceID;
    vec2 vert 		= texelFetch(positions, index).xy + (vertices*scale);
    o_uv 			= texturecoordinates;
    o_technique 	= int(technique);
    o_style 		= 5;
    o_color 		= color;
    o_id 			= uvec2(objectid, index+1);
    gl_Position     = projectionviewmodel * vec4(vert, 0.0, 1); 
}