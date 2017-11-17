{{GLSL_VERSION}}

struct Nothing{ //Nothing type, to encode if some variable doesn't contain any data
    bool _; //empty structs are not allowed
};
struct Grid1D{
    float ref;
    float offset;
    float _step;
    int dims;
};
struct Grid2D{
    vec2 ref;
    vec2 offset;
    vec2 _step;
    ivec2 dims;
};
struct Grid3D{
    vec3 ref;
    vec3 offset;
    vec3 _step;
    ivec3 dims;
};
struct Light{
    vec3 diffuse;
    vec3 specular;
    vec3 ambient;
    vec3 position;
};

// stretch is
vec3 stretch(vec3 val, vec3 from, vec3 to){
    return from + (val * (to - from));
}
vec2 stretch(vec2 val, vec2 from, vec2 to){
    return from + (val * (to - from));
}
float stretch(float val, float from, float to){
    return from + (val * (to - from));
}

float _normalize(float val, float from, float to){return (val-from) / (to - from);}
vec2 _normalize(vec2 val, vec2 from, vec2 to){
    return (val-from) / (to - from);
}
vec3 _normalize(vec3 val, vec3 from, vec3 to){
    return (val-from) / (to - from);
}


mat4 getmodelmatrix(vec3 xyz, vec3 scale){
   return mat4(
      vec4(scale.x, 0, 0, 0),
      vec4(0, scale.y, 0, 0),
      vec4(0, 0, scale.z, 0),
      vec4(xyz, 1));
}

mat4 rotationmatrix_z(float angle){
    return mat4(
        cos(angle), -sin(angle), 0, 0,
        sin(angle), cos(angle), 0,  0,
        0, 0, 1, 0,
        0, 0, 0, 1);
}
mat4 rotationmatrix_y(float angle){
    return mat4(
        cos(angle), 0, sin(angle), 0,
        0, 1, 0, 0,
        -sin(angle), 0, cos(angle), 0,
        0, 0, 0, 1);
}

const vec3 UP_VECTOR = vec3(0,0,1);
mat4 rotation_mat(vec3 direction){
    direction = normalize(direction);
    mat4 rot = mat4(1.0);
    if(direction == UP_VECTOR)
        return rot;
    vec3 xaxis = normalize(cross(UP_VECTOR, direction));

    vec3 yaxis = normalize(cross(direction, xaxis));

    rot[0][0] = xaxis.x;
    rot[1][0] = yaxis.x;
    rot[2][0] = direction.x;

    rot[0][1] = xaxis.y;
    rot[1][1] = yaxis.y;
    rot[2][1] = direction.y;

    rot[0][2] = xaxis.z;
    rot[1][2] = yaxis.z;
    rot[2][2] = direction.z;

    return rot;
}
void rotate(Nothing r, int index, inout vec3 V, inout vec3 N){} // no-op
void rotate(vec3 direction, int index, inout vec3 V, inout vec3 N){
    mat4 rot = rotation_mat(direction);
    V = vec3(rot*vec4(V, 1));
    //N = normalize(vec3(rot*vec4(N, 0)));
}
void rotate(samplerBuffer vectors, int index, inout vec3 V, inout vec3 N){
    vec3 r = texelFetch(vectors, index).xyz;
    rotate(r, index, V, N);
}



mat4 translate_scale(vec3 xyz, vec3 scale){
   return mat4(
      vec4(scale.x, 0, 0, 0),
      vec4(0, scale.y, 0, 0),
      vec4(0, 0, scale.z, 0),
      vec4(xyz, 1));
}

//Mapping 1D index to 1D, 2D and 3D arrays
int ind2sub(int dim, int linearindex){return linearindex;}
ivec2 ind2sub(ivec2 dim, int linearindex){
    return ivec2(linearindex % dim.x, linearindex / dim.x);
}
ivec3 ind2sub(ivec3 dim, int i){
    int z = i / (dim.x*dim.y);
    i -= z * dim.x * dim.y;
    return ivec3(i % dim.x, i / dim.x, z);
}

float linear_index(int dims, int index){
    return float(index) / float(dims);
}
vec2 linear_index(ivec2 dims, int index){
    ivec2 index2D = ind2sub(dims, index);
    return vec2(index2D) / vec2(dims);
}
vec2 linear_index(ivec2 dims, int index, vec2 offset){
    vec2 index2D = vec2(ind2sub(dims, index))+offset;
    return index2D / vec2(dims);
}
vec3 linear_index(ivec3 dims, int index){
    ivec3 index3D = ind2sub(dims, index);
    return vec3(index3D) / vec3(dims);
}
vec4 linear_texture(sampler2D tex, int index){
    return texture(tex, linear_index(textureSize(tex, 0), index));
}

vec4 linear_texture(sampler2D tex, int index, vec2 offset){
    ivec2 dims = textureSize(tex, 0);
    return texture(tex, linear_index(dims, index) + (offset/vec2(dims)));
}

vec4 linear_texture(sampler3D tex, int index){
    return texture(tex, linear_index(textureSize(tex, 0), index));
}
uvec4 getindex(usampler2D tex, int index){
    return texelFetch(tex, ind2sub(textureSize(tex, 0), index), 0);
}
vec4 getindex(samplerBuffer tex, int index){
    return texelFetch(tex, index);
}
vec4 getindex(sampler1D tex, int index){
    return texelFetch(tex, index, 0);
}
vec4 getindex(sampler2D tex, int index){
    return texelFetch(tex, ind2sub(textureSize(tex, 0), index), 0);
}
vec4 getindex(sampler3D tex, int index){
    return texelFetch(tex, ind2sub(textureSize(tex, 0), index), 0);
}



//vec3 _scale(vec3  scale, Nothing scale_x, Nothing scale_y, Nothing scale_z, int index){return scale;}
vec3 _scale(vec2  scale, Nothing scale_x, Nothing scale_y, Nothing scale_z, int index){return vec3(scale,1);}
vec3 _scale(float scale, Nothing scale_x, Nothing scale_y, Nothing scale_z, int index){return vec3(scale);}
vec3 _scale(Nothing  scale, float scale_x, float scale_y, float scale_z, int index){
    return vec3(scale_x, scale_y, scale_z);
}
vec3 _scale(vec2  scale, float scale_x, float scale_y, float scale_z, int index){
    return vec3(scale.x*scale_x, scale.y*scale_y, scale_z);
}
vec3 _scale(vec3  scale, float scale_x, float scale_y, float scale_z, int index){
    return vec3(scale_x, scale_y, scale_z)*scale;
}
vec3 _scale(samplerBuffer scale, Nothing scale_x, Nothing scale_y, Nothing scale_z, int index){
    return getindex(scale, index).xyz;
}
vec3 _scale(vec3 scale, float scale_x, float scale_y, samplerBuffer scale_z, int index){
    return vec3(scale_x, scale_y, getindex(scale_z, index).x);
}
vec3 _scale(Nothing scale, float scale_x, float scale_y, samplerBuffer scale_z, int index){
    return vec3(scale_x, scale_y, getindex(scale_z, index).x);
}
vec3 _scale(vec3 scale, float scale_x, samplerBuffer scale_y, float scale_z, int index){
    return vec3(scale_x, getindex(scale_y, index).x, scale_z);
}
vec3 _scale(Nothing scale, float scale_x, samplerBuffer scale_y, float scale_z, int index){
    return vec3(scale_x, getindex(scale_y, index).x, scale_z);
}

vec4 color_lookup(float intensity, vec4 color, vec2 norm){
    return color;
}
vec4 color_lookup(float intensity, sampler1D color_ramp, vec2 norm){
    return texture(color_ramp, _normalize(intensity, norm.x, norm.y));
}

vec4 _color(vec3 color, Nothing intensity, Nothing color_map, Nothing color_norm, int index, int len){
    return vec4(color, 1);
}
vec4 _color(vec4 color, Nothing intensity, Nothing color_map, Nothing color_norm, int index, int len){return color;}
vec4 _color(samplerBuffer color, Nothing intensity, Nothing color_norm, int index){
    return texelFetch(color, index);
}
vec4 _color(samplerBuffer color, Nothing intensity, Nothing color_map, Nothing color_norm, int index, int len){
    return texelFetch(color, index);
}
vec4 _color(Nothing color, sampler1D intensity, sampler1D color_map, vec2 color_norm, int index, int len){
    return color_lookup(texture(intensity, float(index)/float(len-1)).x, color_map, color_norm);
}
vec4 _color(Nothing color, samplerBuffer intensity, sampler1D color_map, vec2 color_norm, int index, int len){
    return color_lookup(texelFetch(intensity, index).x, color_map, color_norm);
}
vec4 _color(Nothing color, float intensity, sampler1D color_map, vec2 color_norm, int index, int len){
    return color_lookup(intensity, color_map, color_norm);
}



out vec3 o_normal;
out vec3 o_lightdir;
out vec3 o_vertex;


void render(vec3 vertex, vec3 normal, mat4 viewmodel, mat4 projection, vec3 light[4])
{
    vec4 position_camspace = viewmodel * vec4(vertex,  1);
    // normal in world space
    // TODO move transpose inverse calculation to cpu
    o_normal               = vec3(transpose(inverse(viewmodel)) * vec4(normal,0));
    // direction to light
    o_lightdir             = normalize(light[3] - vec3(position_camspace));
    // direction to camera
    o_vertex               = -position_camspace.xyz;
    // screen space coordinates of the vertex
    gl_Position            = projection * position_camspace;
}




bool isinbounds(vec2 uv)
{
    return (uv.x <= 1.0 && uv.y <= 1.0 && uv.x >= 0.0 && uv.y >= 0.0);
}
vec3 getnormal(sampler2D zvalues, vec2 uv)
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
    return normalize(result); // normal should be zero, but needs to be here, because the dead-code elimanation of GLSL is overly enthusiastic
}
