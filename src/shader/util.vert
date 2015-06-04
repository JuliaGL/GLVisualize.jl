{{GLSL_VERSION}}

struct AABB
{
    vec3 min;
    vec3 max;
};
struct Rectangle
{
    vec2 origin;
    vec2 width;
};

// stretch is 
vec3 stretch(vec3 val, vec3 from, vec3 to)
{
    return from + (val * (to - from));
}
vec2 stretch(vec2 val, vec2 from, vec2 to)
{
    return from + (val * (to - from));
}
float stretch(float val, float from, float to)
{
    return from + (val * (to - from));
}

float _normalize(float val, float from, float to)
{
    return (val-from) / (to - from);
}
vec2 _normalize(vec2 val, vec2 from, vec2 to)
{
    return (val-from) * (to - from);
}
vec3 _normalize(vec3 val, vec3 from, vec3 to)
{
    return (val-from) * (to - from);
}


mat4 getmodelmatrix(vec3 xyz, vec3 scale)
{
   return mat4(
      vec4(scale.x, 0, 0, 0),
      vec4(0, scale.y, 0, 0),
      vec4(0, 0, scale.z, 0),
      vec4(xyz, 1));
}

mat4 rotationmatrix_z(float angle)
{
    return mat4(
        cos(angle), -sin(angle), 0, 0,
        sin(angle), cos(angle), 0,  0,
        0, 0, 1, 0,
        0, 0, 0, 1);
}
mat4 rotationmatrix_y(float angle)
{
    return mat4(
        cos(angle), 0, sin(angle), 0,
        0, 1, 0, 0,
        -sin(angle), 0, cos(angle), 0,
        0, 0, 0, 1);
}

const vec3 UP_VECTOR = vec3(0,0,1);

mat4 rotation(vec3 direction)
{
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

mat4 translate_scale(vec3 xyz, vec3 scale)
{
   return mat4(
      vec4(scale.x, 0, 0, 0),
      vec4(0, scale.y, 0, 0),
      vec4(0, 0, scale.z, 0),
      vec4(xyz, 1));
}

//Mapping 1D index to 1D, 2D and 3D arrays
int ind2sub(int dim, int linearindex)
{
    return linearindex;
}
ivec2 ind2sub(ivec2 dim, int linearindex)
{
    return ivec2(linearindex % dim.x, linearindex / dim.x);
}
ivec3 ind2sub(ivec3 dim, int linearindex)
{
    return ivec3(linearindex / (dim.y * dim.z), (linearindex / dim.z) % dim.y, linearindex % dim.z);
}
vec2 linear_index(ivec2 dims, int index)
{
    ivec2 index2D    = ind2sub(dims, index);
    return vec2(index2D) / vec2(dims);
}
vec2 linear_index(ivec2 dims, int index, vec2 offset)
{
    vec2 index2D    = vec2(ind2sub(dims, index))+offset;
    return index2D / vec2(dims);
}
vec3 linear_index(ivec3 dims, int index)
{
    ivec3 index3D = ind2sub(dims, index);
    return vec3(index3D) / vec3(dims);
}
vec4 linear_texture(sampler2D tex, int index)
{
    return texture(tex, linear_index(textureSize(tex, 0), index));
}

vec4 linear_texture(sampler2D tex, int index, vec2 offset)
{   
    ivec2 dims = textureSize(tex, 0);
    return texture(tex, linear_index(dims, index) + (offset/vec2(dims)));
}

vec4 linear_texture(sampler3D tex, int index)
{
    return texture(tex, linear_index(textureSize(tex, 0), index));
}
uvec4 getindex(usampler2D tex, int index)
{
    return texelFetch(tex, ind2sub(textureSize(tex, 0), index), 0);
}
vec4 getindex(sampler2D tex, int index)
{
    return texelFetch(tex, ind2sub(textureSize(tex, 0), index), 0);
}
vec4 getindex(sampler3D tex, int index)
{
    return texelFetch(tex, ind2sub(textureSize(tex, 0), index), 0);
}

//Implicit grid in a Cube via a 3D array
vec3 position(AABB cube, ivec3 dims, int index)
{
    return stretch(linear_index(dims, index), cube.min, cube.max);
}
//Implicit grid on a plane via a 2D array
vec3 position(Rectangle rectangle, ivec2 dims, int index, vec2 offset)
{
    return vec3(stretch(linear_index(dims, index) + offset, rectangle.origin, rectangle.width), 0);
}
vec3 position(Rectangle rectangle, ivec2 dims, int index)
{
    return vec3(stretch(linear_index(dims, index), rectangle.origin, rectangle.width), 0);
}


vec4 color_lookup(float intensity, sampler1D color_ramp, vec2 norm)
{
    return texture(color_ramp, _normalize(intensity, norm.x, norm.y));
}

out vec3 o_normal;
out vec3 o_lightdir;
out vec3 o_vertex;
out vec4 o_color;



void render(vec3 vertex, vec3 normal, vec4 color, mat4 viewmodel, mat4 projection, vec3 light[4])
{
    vec4 position_camspace  = viewmodel * vec4(vertex,  1);
    // normal in world space
    o_normal                = normal;
    // direction to light
    o_lightdir              = normalize(light[3] - vertex);
    // direction to camera
    o_vertex                = -position_camspace.xyz;
    // 
    o_color                 = color;
    // screen space coordinates of the vertex
    gl_Position             = projection * position_camspace; 
}