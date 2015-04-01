{{GLSL_VERSION}}
{{GLSL_EXTENSIONS}}

{{vertex_type}}        vertex;
{{normal_vector_type}} normal_vector; // normal might not be an uniform, whereas the other will be allways uniforms
{{offset_type}}        offset; //offset for texture look up. Needed to get neighbouring vertexes, when rendering the surface

{{x_type}} x; 
{{y_type}} y;
{{z_type}} z;   

{{xscale_type}} xscale; 
{{yscale_type}} yscale; 
{{zscale_type}} zscale;

{{color_type}} color;

uniform vec2 griddimensions;
uniform mat3 normalmatrix;
uniform mat4 projection, view, model;
uniform bool interpolate;


{{out}} vec3 V;

/**
Function that fetches a float value, depending on what type is given
*/
float fetch1stvalue(ivec2 position, sampler2D tex)
{
    return texelFetch(tex, position, 0).x;
}
float fetch1stvalue(int index, vec2 range)
{
    float from  = range.x;
    float to    = range.y;
    return from + (float(index)/griddimensions.x) * (to - from);
}
float fetch1stvalue(int index, float value)
{
    return value;
}

float fetch1stvalue(vec2 position, sampler2D tex)
{
    return texture(tex, position).x;
}
float fetch1stvalue(vec2 index, float value)
{
    return value;
}
float fetch1stvalue(float position, vec2 range)
{
    float from  = range.x;
    float to    = range.y;
    return from + position * (to - from);
}


mat4 getmodelmatrix(vec3 xyz, vec3 scale)
{
   return mat4(
      vec4(scale.x, 0, 0, 0),
      vec4(0, scale.y, 0, 0),
      vec4(0, 0, scale.z, 0),
      vec4(xyz, 1));
}

void main(){
    vec3 xyz, scale, normal, vert;
    int index   = gl_InstanceID;
    ivec2 ij    = ivec2(index / int(griddimensions.x), index % int(griddimensions.x));
    vec2 uv     = (vec2(ij)+offset) / griddimensions;

    xyz.x       = fetch1stvalue(uv.x, x);
    xyz.y       = fetch1stvalue(uv.y, y);
    xyz.z       = fetch1stvalue(ij, z);

    scale.x     = fetch1stvalue(ij, xscale);
    scale.y     = fetch1stvalue(ij, yscale);
    scale.z     = fetch1stvalue(ij, zscale);

    vert        = {{vertex_calculation}}
    V           = xyz;
    gl_Position = vec4(0,0,0,1);
}
