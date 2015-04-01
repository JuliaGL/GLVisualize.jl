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


{{out}} vec3 N;
{{out}} vec3 V;
{{out}} vec4 vert_color;

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
bool isinbounds(vec2 uv)
{
    return (uv.x <= 1.0 && uv.y <= 1.0 && uv.x >= 0.0 && uv.y >= 0.0);
}

vec3 getnormal(sampler2D zvalues, vec2 uv, float normal)
{   
    float weps = 1.0/textureSize(zvalues,0).x;
    float heps = 1.0/textureSize(zvalues,0).y;

    vec3 result = vec3(0);
    
    vec3 s0 = vec3(uv, texture(zvalues, uv).x);

    vec2 off1 = uv + vec2(-weps,0);
    vec2 off2 = uv + vec2(0, heps);
    vec2 off3 = uv + vec2(weps, 0);
    vec2 off4 = uv + vec2(0,-heps);
    vec3 s1, s2, s3, s4;

    s1 = vec3((off1), texture(zvalues, off1).x);
    s2 = vec3((off2), texture(zvalues, off2).x);
    s3 = vec3((off3), texture(zvalues, off3).x);
    s4 = vec3((off4), texture(zvalues, off4).x);

    if(isinbounds(off1) && isinbounds(off2))
    {
        result += cross(s2-s0, s1-s0);
    }
    if(isinbounds(off2) && isinbounds(off3))
    {
        result += cross(s3-s0, s2-s0);
    }
    if(isinbounds(off3) && isinbounds(off4))
    {
        result += cross(s4-s0, s3-s0);
    }
    if(isinbounds(off4) && isinbounds(off1))
    {
        result += cross(s1-s0, s4-s0);
    }

    return normalize(result + normal); // normal should be zero, but needs to be here, because the dead-code elimanation of GLSL is overly enthusiastic
}

vec3 getnormal(float zvalues, vec2 uv, vec3 normal)
{
    return normal;
}
vec2 getcoordinate(sampler2D xvalues, sampler2D yvalues, vec2 uv)
{
    return vec2(texture(xvalues, uv).x, texture(yvalues, uv).x);
}
vec2 getcoordinate(vec2 xrange, vec2 yrange, vec2 uv)
{
    vec2 from = vec2(xrange.x, yrange.x);
    vec2 to = vec2(xrange.y, yrange.y);
    return from + (uv * (to - from));
}
vec2 getuv(vec2 texdim, int index, vec2 offset)
{
    float u = float((index % int(texdim.x)));
    float v = float((index / int(texdim.x)));
    return (vec2(u,v) + offset) / (texdim);
}
ivec2 get2Dindex(int index1D, sampler2D tex)
{
    return ivec2(gl_InstanceID % textureSize(tex, 0).x, gl_InstanceID / textureSize(tex, 0).x);
}


vec4 fetchrgba(int index, sampler2D tex)
{
    vec2 position = vec2(gl_InstanceID % textureSize(tex, 0).x, gl_InstanceID / textureSize(tex, 0).x);
    return texture(tex, position / vec2(textureSize(tex, 0)) ).rgba;
}
vec4 fetchrgba(int index, vec4 rgba)
{
    return rgba;
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
    xyz.z       = fetch1stvalue(uv, z);

    scale.x     = fetch1stvalue(uv, xscale);
    scale.y     = fetch1stvalue(uv, yscale);
    scale.z     = fetch1stvalue(ij, zscale);
    

    normal      = getnormal(z, uv, normal_vector);
    N           = normalize(normalmatrix * normal);

    vert_color  = {{color_calculation}}

    
    vert        = {{vertex_calculation}}
    vec4 v      = view * model * getmodelmatrix(xyz, scale) * vec4(vert.xyz, 1.0);
    V           = vec3(v);

    gl_Position = projection * v;
}
