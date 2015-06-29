{{GLSL_VERSION}}

in vec3 vertex;

out vec4 o_color;

{{color_type}} color;

ivec2 ind2sub(ivec2 dim, int linearindex)
{
    return ivec2(linearindex % dim.x, linearindex / dim.x);
}
vec4 getindex(sampler2D tex, int index)
{
    return texelFetch(tex, ind2sub(textureSize(tex, 0), index), 0);
}

uniform mat4 projectionview, model;

void main()
{
	int index   = gl_VertexID;
	vec3 c 		= {{color_calculation}}
	o_color 	= vec4(c, 1.0);
	gl_Position = projectionview*model * vec4(vertex, 1);
}