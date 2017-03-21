{{GLSL_VERSION}}

struct Nothing{ //Nothing type, to encode if some variable doesn't contain any data
    bool _; //empty structs are not allowed
};
in vec3 frag_vert;
in vec3 frag_uv;

uniform sampler3D intensities;

uniform vec3 light_position = vec3(1.0, 1.0, 3.0);
uniform vec3 light_intensity = vec3(15.0);
{{color_map_type}} color_map;
{{color_type}} color;
{{color_norm_type}} color_norm;

uniform float absorption = 20.0;

uniform vec3 eyeposition;

uniform vec3 ambient = vec3(0.15, 0.15, 0.20);

uniform mat4 modelinv;
uniform int algorithm;
uniform float isovalue;
uniform float isorange;

const float max_distance = 1.0;

const int num_samples = 128;
const float step_size = max_distance / float(num_samples);
const int num_ligth_samples = 16;
const float lscale = max_distance / float(num_ligth_samples);
const float density_factor = 9;

const float eps = 0.0001;
bool intersect(vec3 ray_origin, vec3 ray_dir, vec3 center, vec3 normal, out vec3 intersect){
    float denom = dot(normal, ray_dir);
    if (abs(denom) > eps) // if not orthogonal
    {
        float t = dot(center - ray_origin, normal) / denom;
        if (t >= 0){
            intersect.xyz = ray_origin + (ray_dir * t);
            return true;
        }
    }
    return false;
}
float _normalize(float val, float from, float to)
{
    return (val-from) / (to - from);
}

vec4 color_lookup(float intensity, Nothing color_map, Nothing norm, vec4 color)
{
    return color;
}

vec4 color_lookup(float intensity, samplerBuffer color_ramp, vec2 norm, Nothing color)
{
    return texelFetch(color_ramp, int(_normalize(intensity, norm.x, norm.y)*textureSize(color_ramp)));
}

vec4 color_lookup(float intensity, sampler1D color_ramp, vec2 norm, Nothing color)
{
    return texture(color_ramp, _normalize(intensity, norm.x, norm.y));
}


float GetDensity(vec3 pos)
{
    return texture(intensities, pos).x;
}

vec3 gennormal(vec3 uvw, vec3 gradient_delta)
{
    vec3 a,b;
    a.x = texture(intensities, uvw - vec3(gradient_delta.x,0.0,0.0) ).r;
    b.x = texture(intensities, uvw + vec3(gradient_delta.x,0.0,0.0) ).r;
    a.y = texture(intensities, uvw - vec3(0.0,gradient_delta.y,0.0) ).r;
    b.y = texture(intensities, uvw + vec3(0.0,gradient_delta.y,0.0) ).r;
    a.z = texture(intensities, uvw - vec3(0.0,0.0,gradient_delta.z) ).r;
    b.z = texture(intensities, uvw + vec3(0.0,0.0,gradient_delta.z) ).r;
    return normalize(a - b);
}

vec3 blinn_phong(vec3 N, vec3 V, vec3 L, vec3 diffuse)
{
    // material properties
    vec3 Ka = vec3(0.1);
    vec3 Kd = vec3(1.0, 1.0, 1.0);
    vec3 Ks = vec3(1.0, 1.0, 1.0);
    float shininess = 50.0;

    // diffuse coefficient
    float diff_coeff = max(dot(L,N),0.0);

    // specular coefficient
    vec3 H = normalize(L+V);
    float spec_coeff = pow(max(dot(H,N), 0.0), shininess);
    if (diff_coeff <= 0.0)
        spec_coeff = 0.0;

    // final lighting model
    return  Ka * vec3(0.5) +
            Kd * diffuse * diff_coeff +
            Ks * vec3(0.3) * spec_coeff ;
}

bool is_outside(vec3 position)
{
    return (position.x > 1.0 || position.y > 1.0 || position.z > 1.0 || position.x < 0.0 || position.y < 0.0 || position.z < 0.0);
}


vec4 volume(vec3 front, vec3 dir, float stepsize)
{
    vec3  stepsize_dir = normalize(dir) * stepsize;
    vec3  pos = front;
    float T = 1.0;
    vec3 Lo = vec3(0.0);
    int i = 0;
    pos += stepsize_dir;//apply first, to padd
    for (i; i < num_samples && (!is_outside(pos) || i < 3); ++i, pos += stepsize_dir) {

        float density = texture(intensities, pos).x * density_factor;
        if (density <= 0.0)
            continue;

        T *= 1.0-density*stepsize*absorption;
        if (T <= 0.01)
            break;

        vec3 lightDir = normalize(light_position-pos)*lscale;
        float Tl = 1.0;
        vec3 lpos = pos + lightDir;
        int s = 0;
        for (s; s < num_ligth_samples; ++s) {
            float ld = texture(intensities, lpos).x;
            Tl *= 1.0-absorption*stepsize*ld;
            if (Tl <= 0.01)
            lpos += lightDir;
        }

        vec3 Li = light_intensity*Tl;
        Lo += Li*T*density*stepsize;
    }
    return vec4(Lo, 1-T);
}
vec4 isosurface(vec3 front, vec3 dir, float stepsize)
{
    vec3  stepsize_dir  = dir * stepsize;
    vec3  pos           = front;
    vec3  Lo            = vec3(0.0);
    int   i             = 0;
    vec4 _color         = vec4(0.0);
    pos += stepsize_dir;//apply first, to padd
    vec4 difuse_color   = color_lookup(isovalue, color_map, color_norm, color);

    for (i; i < num_samples && (!is_outside(pos) || i == 1); ++i, pos += stepsize_dir)
    {
        float density = texture(intensities, pos).x;
        if (density <= 0.0)
            continue;
        if(abs(density - isovalue) < isorange)
        {
            vec3 N = gennormal(pos, vec3(stepsize));
            vec3 L = normalize(light_position - pos);
            vec3 L2 = -L;
            Lo = blinn_phong(N, pos, L, difuse_color.rgb);
            Lo += blinn_phong(N, pos, L2, difuse_color.rgb);
            _color = vec4(Lo, 1);
            break;
        }
    }
    return _color;
}

vec4 mip(vec3 front, vec3 dir, float stepsize)
{
    vec3 stepsize_dir = dir * stepsize;
    vec3 pos = front;
    int i = 0;
    pos += stepsize_dir;//apply first, to padd
    float maximum = 0.0;
    for (i; i < num_samples && !is_outside(pos); ++i, pos += stepsize_dir)
    {
        float density = texture(intensities, pos).x;
        if(maximum < density)
            maximum = density;
    }
    return color_lookup(maximum, color_map, color_norm, color);
}

uniform uint objectid;

void write2framebuffer(vec4 color, uvec2 id);

void main()
{
    vec4 color;
    vec3 dir = normalize(frag_vert - eyeposition);
    dir = vec3(modelinv * vec4(dir, 0));
    if(algorithm == 0)
        color = isosurface(frag_uv, dir, step_size);
    else if(algorithm == 1)
        color = volume(frag_uv, dir, step_size);
    else
        color = mip(frag_uv, dir, step_size);

    write2framebuffer(color, uvec2(objectid, 0));
}
