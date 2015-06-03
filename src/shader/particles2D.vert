{{GLSL_VERSION}}
{{GLSL_EXTENSIONS}}

in vec2 vertices;
in vec2 texturecoordinates;

uniform vec3 light[4];
uniform vec4 particle_color;

uniform sampler2D positions;

uniform mat4 projectionviewmodel;

vec4 getindex(sampler2D tex, int index);


out vec2 o_uv;
out vec4 o_color;


void main(){
    vec2 vert 		= getindex(positions, gl_InstanceID).xy + vertices;
    o_uv 			= texturecoordinates;
    o_color 		= particle_color;
    gl_Position     = projectionviewmodel * vec4(vert, 0.0, 1); 
}