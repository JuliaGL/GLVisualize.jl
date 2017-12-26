{{GLSL_VERSION}}
///////////////////////////////////////////////////////////////////////////////
const int numberoflights = 5;
uniform vec3 ambientcolor;// = vec3(0.3, 0.3, 0.3);
uniform vec4 material; // = vec4(1., 0.4, 0.5, 1.);
/*
(ambient, diffuse, specular, specularcolorcoeff) ∈ [0, 1]
default vec4(1., 0.4, 0.5, 1.);
*/
uniform float shininess;
struct lightSource
{
    vec3 color;
    vec3 position;
    int onoff; // == 0 or 1
};
uniform vec3 lightposition1;
uniform vec3 lightposition2;
uniform vec3 lightposition3;
uniform vec3 lightposition4;
uniform vec3 lightposition5;
uniform vec3 lightcolor1;
uniform vec3 lightcolor2;
uniform vec3 lightcolor3;
uniform vec3 lightcolor4;
uniform vec3 lightcolor5;
uniform int onoff1; uniform int onoff2;
uniform int onoff3; uniform int onoff4; uniform int onoff5;
lightSource light0 = lightSource(
    lightcolor1,    // color
    lightposition1,      // position
    onoff1
);
lightSource light1 = lightSource(
    lightcolor2,    // color
    lightposition2,      // position
    onoff2
);
lightSource light2 = lightSource(
    lightcolor3,    // color
    lightposition3,      // position
    onoff3
);
lightSource light3 = lightSource(
    lightcolor4,    // color
    lightposition4,      // position
    onoff4
);
lightSource light4 = lightSource(
    lightcolor5,    // color
    lightposition5,      // position
    onoff5
);
lightSource lights[numberoflights];
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
vec3 blinnphong(vec3 N, vec3 V, vec3 color){
    // define lights
    lights[0] = light0;
    lights[1] = light1;
    lights[2] = light2;
    lights[3] = light3;
    lights[4] = light4;
    // initialize total lighting with ambient lighting
    vec3 totalLighting = material[0] * vec3(ambientcolor);

    for (int index = 0; index < numberoflights; index++) // for all light sources
    {
        if (lights[index].onoff == 1)
        {
            vec3 L = normalize(vec3(lights[index].position) - V);

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
