{{GLSL_VERSION}}

{{in}} vec4 V;

{{out}} vec4 minbuffer;
{{out}} vec4 maxbuffer;

void main()
{
	minbuffer = -V;
	maxbuffer = V;
}