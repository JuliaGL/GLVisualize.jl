{{GLSL_VERSION}}

///////////////////////////////////////////////////////////////////////////////
uniform vec3 ambientcolor;
const int numberOfLights = 5;
struct lightSource
{
    vec3 color;
    vec3 position;
    int onoff; // == 0 or 1
};
uniform vec3 position1;
uniform vec3 position2;
uniform vec3 position3;
uniform vec3 position4;
uniform vec3 position5;
uniform vec3 colorlight1;
uniform vec3 colorlight2;
uniform vec3 colorlight3;
uniform vec3 colorlight4;
uniform vec3 colorlight5;
uniform int onoff1; uniform int onoff2;
uniform int onoff3; uniform int onoff4; uniform int onoff5;
lightSource light0 = lightSource(
    colorlight1,    // color
    position1,      // position
    onoff1
);
lightSource light1 = lightSource(
    colorlight2,    // color
    position2,      // position
    onoff2
);
lightSource light2 = lightSource(
    colorlight3,    // color
    position3,      // position
    onoff3
);
lightSource light3 = lightSource(
    colorlight4,    // color
    position4,      // position
    onoff4
);
lightSource light4 = lightSource(
    colorlight5,    // color
    position5,      // position
    onoff5
);
lightSource lights[numberOfLights];
uniform vec4 material; //vec4(1., 0.4, 0.5, 1.);
/*
(ambient, diffuse, specular, specularcolorcoeff) ∈ [0, 1]
default vec4(1., 0.4, 0.5, 1.);
*/
uniform float shininess;
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

/*
1) L light direction still needed as input parameters?
2) Term pow(max(0.0, dot(reflect(-L, N), V)), shininess) different
   from first implementation??
*/
vec3 blinnphong(vec3 N, vec3 V, vec3 L, vec3 color){

    // define lights
    lights[0] = light0;
    lights[1] = light1;
    lights[2] = light2;
    lights[3] = light3;
    lights[4] = light4;
    // initialize total lighting with ambient lighting
    vec3 totalLighting = material[0] * vec3(ambientcolor);

    for (int index = 0; index < numberOfLights; index++) // for all light sources
    {
        if (lights[index].onoff == 1)
        {
            //??? L
            L = normalize(vec3(lights[index].position));

            vec3 diffuseReflection = material[1] * vec3(lights[index].color) *
                                     max(0.0, dot(N, L)) * color;

            vec3 specularReflection;
            if (dot(N, L) < 0.0) // light source on the wrong side?
            {
                specularReflection = vec3(0.0, 0.0, 0.0); // no specular reflection
            }
            else // light source on the right side
            {
                vec3 specularcolor = (1 - material[3]) * vec3(lights[index].color) +
                                      material[3] *vec3(1);
                specularReflection = material[2] * vec3(specularcolor) *
                                     pow(max(dot(L, N), 0.0), shininess);
            }
            totalLighting = totalLighting + diffuseReflection + specularReflection;
        }
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
