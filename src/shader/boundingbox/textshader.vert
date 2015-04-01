{{GLSL_VERSION}}
{{GLSL_EXTENSIONS}}

// Input vertex data, different for all executions of this shader.
{{in}} int uv_index;

// Values that stay constant for the whole mesh.

{{offset_type}} offset;

{{color_type}} color;
uniform sampler1D style_group;
{{backgroundcolor_type}} backgroundcolor;
//{{style_type}} style;

{{text_type}} text;

uniform vec3 newline;
uniform vec3 advance;

uniform sampler2D uv;

uniform mat4 model;

{{out}} vec4 V;


int texturewidth(usampler1D x)
{
	return textureSize(x, 0);
}
int texturewidth(sampler1D x)
{
	return textureSize(x, 0);
}
int texturewidth(usampler2D x)
{
	return textureSize(x, 0).x;
}
int texturewidth(sampler2D x)
{
	return textureSize(x, 0).x;
}
vec3 qmult(vec4 q, vec3 v) 
{
    vec3 t = 2 * cross(vec3(q.y, q.z, q.w), v);
    return v + q.x * t + cross(vec3(q.y, q.z, q.w), t);
}

int fetchglyph(usampler1D glyphs, int index)
{
	return int(texelFetch(glyphs, index, 0).r);
}
uvec4 fetchglyph(usampler2D glyphs, int index)
{
	int width = texturewidth(glyphs);
	return texelFetch(glyphs, ivec2(index % width, index/width), 0).rgba;
}

vec3 position(int index, usampler2D offset)
{
	int width     = texturewidth(offset);
	ivec2 tindex  = ivec2(index % width, index / width);
	float linemultiplikator    = float(texelFetch(offset, tindex, 0).x);
	float advancemultiplikator = float(texelFetch(offset, tindex, 0).y);
	return (linemultiplikator * newline) + (advancemultiplikator * advance);
}
vec3 position(int index, sampler2D offset)
{
	int width = texturewidth(offset);
	return texelFetch(offset, ivec2(index % width, index / width), 0).xyz;
}

vec3 position(int index, sampler1D offset)
{
	int width 		= texturewidth(offset);
	int line 		= index % width;
	int linepos		= index / width;
	vec3 advance 	= texelFetch(offset, line, 0).xyz;
	vec3 newline 	= texelFetch(offset, line, 0).xyz;

	return (line*newline) + (linepos*advance);
}

vec3 position(int index, vec2 offset)
{
	int width 				 = texturewidth(text);
	int linemultiplikator    = index / width;
	int advancemultiplikator = index % width;

	return (linemultiplikator * newline) + (advancemultiplikator * advance);
}
vec3 position(int index, vec3 offset)
{
	return index*offset;
}

vec4 fetchtexture(sampler2D tex, int index)
{
    int width = texturewidth(tex);
    return texelFetch(tex, ivec2(index % width, index/width), 0).rgba;
}
uvec4 fetchtexture(usampler2D tex, int index)
{
    int width = texturewidth(tex);
    return texelFetch(tex, ivec2(index % width, index/width), 0).rgba;
}
const int SPACE 	= 32;
const int NEWLINE 	= 10;

void main(){

	int index 		   = gl_InstanceID;
	
	ivec4 textvalues   = ivec4(fetchglyph(text, index));
	int glyph 		   = textvalues.x;

	vec3 glyphposition = (textvalues.y * newline) + (textvalues.z * advance);

	vec3 vertex 	= glyphposition; // if uv_index is vert 1 or 6
	if (uv_index == 2)
	{
		vertex = glyphposition + vec3(0,24,0);
	}
	else if  ((uv_index == 3) || (uv_index == 4))
	{
		vertex = glyphposition + vec3(12, 24,0);
	}
	else if (uv_index == 5)
	{
		vertex = glyphposition + vec3(12,0,0);
	}

	V = vec4(vertex, 0);
	gl_Position = vec4(0,0,0,1);
}
