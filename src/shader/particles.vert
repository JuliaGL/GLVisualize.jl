{{GLSL_VERSION}}
{{GLSL_EXTENSIONS}}

in vec3 vertices;
in vec3 normals;

uniform vec3 light[4];
struct Nothing{ //Nothing type, to encode if some variable doesn't contain any data
    bool _; //empty structs are not allowed
};

{{position_type}} position;
Nothing position_x;
Nothing position_y;
Nothing position_z;
Nothing intensity;

{{scale_type}} scale; // so in the case of distinct x,y,z, there's no chance to unify them under one variable
Nothing scale_x;
Nothing scale_y;
Nothing scale_z;

{{rotation_type}}   rotation;
{{color_type}}      color;
{{color_norm_type}} color_norm;

uniform mat4 view, model, projection;
void render(vec3 vertices, vec3 normals, mat4 viewmodel, mat4 projection, vec3 light[4]);

vec4 getindex(sampler2D tex, int index);
vec4 getindex(sampler1D tex, int index);
vec4 getindex(samplerBuffer tex, int index);
vec4 color_lookup(float intensity, vec4 color, vec2 norm);
vec4 color_lookup(float intensity, sampler1D color_ramp, vec2 norm);

uniform uint objectid;
flat out uvec2 o_id;
out vec4 o_color;

const vec3 UP_VECTOR = vec3(0,0,1);
mat4 rotation_mat(vec3 direction)
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

void rotate(Nothing r, int index, in vec3 vertices, in vec3 normal){} // no-op
void rotate(samplerBuffer vectors, int index, inout vec3 V, inout vec3 N)
{
    vec3 r = texelFetch(vectors, index).xyz;
    mat4 rot = rotation_mat(r);
    V = vec3(rot*vec4(V, 1));
    N = normalize(vec3(rot*vec4(N, 1)));
}
void rotate(vec3 direction, in vec3 vertices, in vec3 normal, int index){} 

void colorize(vec4 color, int index, Nothing intensity, Nothing color_norm)
{
    o_color = color;
}
void colorize(samplerBuffer color, int index, Nothing intensity, Nothing color_norm)
{
    o_color = texelFetch(color, index);
}
void colorize(sampler1D color, int index, samplerBuffer intensity, vec2 color_norm)
{
    o_color = color_lookup(texelFetch(intensity, index).x, color, color_norm);
}
vec3 _position(samplerBuffer position, Nothing position_x, Nothing position_y, Nothing position_z, int index)
{
    return texelFetch(position, index).xyz;
}
vec3 _position(Nothing position, samplerBuffer position_x, samplerBuffer position_y, samplerBuffer position_z, int index)
{
    return vec3(texelFetch(position_x, index).x, texelFetch(position_y, index).x, texelFetch(position_z, index).x);
}
//vec3 position(AABB cube, Nothing position_x, Nothing position_y, Nothing position_z, int index);
//vec3 position(Rectangle rect, Nothing position_x, Nothing position_y, Nothing position_z, int index);
void scale_it(Nothing scale, Nothing scale_x, Nothing scale_y, Nothing scale_z, int index, inout vec3 V){}
void scale_it(vec3 scale, Nothing scale_x, Nothing scale_y, Nothing scale_z, int index, inout vec3 V){V *= scale;}
void scale_it(samplerBuffer scale, Nothing scale_x, Nothing scale_y, Nothing scale_z, int index, inout vec3 V){
    V *= getindex(scale, index).xyz;
}


void main(){
	int index = gl_InstanceID;
	vec3 pos  = _position(position, position_x, position_y, position_z, index);
    vec3 V = vertices;
    vec3 N = normals;


    scale_it(scale, scale_x, scale_y, scale_z, index, V);
    rotate(rotation, index, V, N);
    colorize(color, index, intensity, color_norm);

    o_id = uvec2(objectid, index);
    render(pos + V, N, view*model, projection, light);
}