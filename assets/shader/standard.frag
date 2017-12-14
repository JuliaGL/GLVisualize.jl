{{GLSL_VERSION}}
///////////////////////////////////////////////////////////////////////////////
// light stuff
// WARNING to be defined for spot lights ??? Varying, in/out ?
vec4 position = vec4(0.0,  1.0,  2.0, 1.0);  // position of the vertex (and fragment) in world space
//

struct lightSource
{
  vec4 position;
  vec4 diffuse;
  vec4 specular;
  float constantAttenuation, linearAttenuation, quadraticAttenuation;
  float spotCutoff, spotExponent;
  vec3 spotDirection;
};
const int numberOfLights = 1;
lightSource lights[numberOfLights];
lightSource light0 = lightSource(
  vec4(10.0,  10.0,  20.0, 0.0),  // last coordinate 1 <-> 0 to avoid spot light WARNING
  vec4(1.0,  1.0,  1.0, 1.0),
  vec4(1.0,  1.0,  1.0, 1.0),
  0.0, 1.0, 0.0,
  180.0, 0.0,
  vec3(0.0, 0.0, 0.0)
);
lightSource light1 = lightSource(
    vec4(0.0, -20.0,  10.0, 0.0), // last coordinate 1 <-> 0 to avoid spot light WARNING
    vec4(2.0,  0.0,  0.0, 1.0),
    vec4(0.1,  0.1,  0.1, 1.0),
    0.0, 1.0, 0.0,
    80.0, 10.0,
    vec3(0.0, 1.0, 0.0)
);
vec4 scene_ambient = vec4(0.2, 0.2, 0.2, 1.0);

struct material
{
  vec4 ambient;
  vec4 diffuse;
  vec4 specular;
  float shininess;
};
material frontMaterial = material(
  vec4(0.2, 0.2, 0.2, 1.0),
  vec4(1.0, 0.8, 0.8, 1.0),
  vec4(1.0, 1.0, 1.0, 1.0),
  5.0);
///////////////////////////////////////////////////////////////////////////////
struct Nothing{ //Nothing type, to encode if some variable doesn't contain any data
    bool _; //empty structs are not allowed
};

in vec3 o_normal;
in vec3 o_lightdir;
in vec3 o_vertex;
in vec4 o_color;
in vec2 o_uv;
flat in uvec2 o_id;

{{color_type}} color;

vec4 get_color(vec3 color, vec2 uv){
    return vec4(color, 1.0 + (0.0 * uv)); // we must prohibit uv from getting into dead variable removal
}

vec4 get_color(vec4 color, vec2 uv){
    return color + uv.x * 0.0; // we must prohibit uv from getting into dead variable removal
}

vec4 get_color(Nothing color, vec2 uv){
    return o_color + uv.x * 0.0;
}
vec4 get_color(samplerBuffer color, vec2 uv){
    return o_color + uv.x * 0.0;
}

vec4 get_color(sampler2D color, vec2 uv){
    return texture(color, uv);
}

vec3 blinnphong(vec3 N, vec3 V, vec3 L, vec3 color){
    // WARNING fix variable number of lights
    lights[0] = light0;
    //lights[1] = light1;

    float attenuation;
    // initialize total lighting with ambient lighting
    vec3 totalLighting = vec3(scene_ambient) * vec3(frontMaterial.ambient);

    for (int index = 0; index < numberOfLights; index++) // for all light sources
    {
        if (0.0 == lights[index].position.w) // directional light?
        {
            attenuation = 1.0; // no attenuation
            L = normalize(vec3(lights[index].position));
        }
        else // point light or spotlight (or other kind of light)
        {
            vec3 positionToLightSource = vec3(lights[index].position - position);
            float distance = length(positionToLightSource);
            L = normalize(positionToLightSource);
            attenuation = 1.0 / (lights[index].constantAttenuation
                + lights[index].linearAttenuation * distance
                + lights[index].quadraticAttenuation * distance * distance);

                if (lights[index].spotCutoff <= 90.0) // spotlight?
                {
                    float clampedCosine = max(0.0, dot(-L, normalize(lights[index].spotDirection)));
                    if (clampedCosine < cos(radians(lights[index].spotCutoff))) // outside of spotlight cone?
                    {
                        attenuation = 0.0;
                    }
                    else
                    {
                        attenuation = attenuation * pow(clampedCosine, lights[index].spotExponent);
                    }
                }
        }
        // WARNING
        // color only added here which do not correspond to the tuto. OK ????
        vec3 diffuseReflection = attenuation
        * vec3(lights[index].diffuse) * vec3(frontMaterial.diffuse)
        * max(0.0, dot(N, L)) * color;

        vec3 specularReflection;
        if (dot(N, L) < 0.0) // light source on the wrong side?
        {
            specularReflection = vec3(0.0, 0.0, 0.0); // no specular reflection
        }
        else // light source on the right side
        {
            specularReflection = attenuation * vec3(lights[index].specular) * vec3(frontMaterial.specular)
            * pow(max(0.0, dot(reflect(-L, N), V)), frontMaterial.shininess);
        }

        totalLighting = totalLighting + diffuseReflection + specularReflection;
    }
    return totalLighting;
}


void write2framebuffer(vec4 color, uvec2 id);

void main(){
    vec4 color = get_color(color, o_uv);
    {{light_calc}}
    write2framebuffer(
        color,
        o_id
    );
}
