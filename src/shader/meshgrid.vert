{{GLSL_VERSION}}
{{GLSL_EXTENSIONS}}

struct Rectangle
{
    vec2 origin;
    vec2 width;
};

in vec3 vertices;
in vec3 normals;

uniform vec3 light[4];
uniform sampler1D color;
uniform vec2 color_norm;

uniform sampler2D y_scale;
uniform vec3 scale;

uniform vec2 grid_min;
uniform vec2 grid_max;

uniform mat4 view, model, projection;

void render(vec3 vertices, vec3 normals, vec4 color, mat4 viewmodel, mat4 projection, vec3 light[4]);

vec3 position(Rectangle rectangle, ivec2 dims, int index);
vec4 getindex(sampler2D tex, int index);
vec4 color_lookup(float intensity, sampler1D color_ramp, vec2 color_norm);

uniform uint objectid;
flat out uvec2 o_id;

void main()
{
	vec3 pos 		= position(Rectangle(grid_min, grid_max), textureSize(y_scale, 0), gl_InstanceID);
	float intensity = getindex(y_scale, gl_InstanceID).x;
	pos 				+= vertices*vec3(scale.xy, scale.z*intensity);
	vec4 instance_color = color_lookup(intensity, color, color_norm);
	render(pos, normals, instance_color, view*model, projection, light);
	o_id = uvec2(objectid, gl_InstanceID);  
}


