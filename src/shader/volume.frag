{{GLSL_VERSION}}

out vec4 frag_color;
in vec3 frag_vertposition;

uniform sampler3D intensity;

uniform vec3 light_position = vec3(1.0, 1.0, 3.0);
uniform vec3 light_intensity = vec3(15.0);
uniform float absorption = 1.0;

uniform vec3 eye_position;

uniform mat4 model;

uniform vec3 ambient = vec3(0.15, 0.15, 0.20);

const int view_samples = 256;
const float max_distance = sqrt(1.0);

const int num_samples = 512;
const float step_size = max_distance/float(num_samples);
const int num_ligth_samples = 32;
const float lscale = max_distance / float(num_ligth_samples);
const float density_factor =9;



float GetDensity(vec3 pos)
{
    return texture(intensity, pos).x;
}

vec3 gennormal(vec3 uvw, vec3 gradient_delta)
{
    vec3 a,b;
    a.x = texture(intensity, uvw -vec3(gradient_delta.x,0.0,0.0) ).r;
    b.x = texture(intensity, uvw +vec3(gradient_delta.x,0.0,0.0) ).r;
    a.y = texture(intensity, uvw -vec3(0.0,gradient_delta.y,0.0) ).r;
    b.y = texture(intensity, uvw +vec3(0.0,gradient_delta.y,0.0) ).r;
    a.z = texture(intensity, uvw -vec3(0.0,0.0,gradient_delta.z) ).r;
    b.z = texture(intensity, uvw +vec3(0.0,0.0,gradient_delta.z) ).r;
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
    vec3  stepsize_dir   = normalize(dir) * stepsize;
    vec3  pos            = front;
    float T = 1.0;
    vec3 Lo = vec3(0.0);
    int i = 0;
    pos += stepsize_dir;//apply first, to padd
    for (i; i < num_samples && (!is_outside(pos) || i<3); ++i, pos += stepsize_dir) {

        float density = texture(intensity, pos).x * density_factor;
        if (density <= 0.0)
            continue;

        T *= 1.0-density*stepsize*absorption;
        if (T <= 0.01)
            break;

        vec3 lightDir = normalize(light_position-pos)*lscale;
        float Tl = 1.0;
        vec3 lpos = pos + lightDir;
        int s=0;
        for (s; s < num_ligth_samples; ++s) {
            float ld = texture(intensity, lpos).x;
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
    pos += stepsize_dir;//apply first, to padd
    for (i; i < num_samples && (!is_outside(pos) || i==1); ++i, pos += stepsize_dir) 
    {
        float density = texture(intensity, pos).x;
        if (density <= 0.0)
            continue;
        if(abs(density - 0.12) < 0.06)
        {
            vec3 N = gennormal(pos, vec3(stepsize));
            vec3 L = normalize(light_position - pos);
            vec3 L2 = -L;
            Lo     = blinn_phong(N, pos, L, vec3(1,0,0));
            Lo     += blinn_phong(N, pos, L2, vec3(1,0,0));
            break;
        }
    }
    return vec4(Lo, 1);
}
vec4 mip(vec3 front, vec3 dir, float stepsize)
{
    vec3  stepsize_dir  = dir * stepsize;
    vec3  pos           = front;
    vec3  Lo            = vec3(0.0);
    int   i             = 0;
    pos += stepsize_dir;//apply first, to padd
    float maximum        = 0.0;
    for (i; i < num_samples && (!is_outside(pos) || i==1); ++i, pos += stepsize_dir) 
    {
        float density = texture(intensity, pos).x;
        if (density <= 0.0)
            continue;
        if(maximum < density)
        {
            maximum = density;
        }
    }
    return vec4(maximum);
}
void main()
{
    frag_color = isosurface(frag_vertposition, normalize(frag_vertposition-eye_position), step_size);
}

