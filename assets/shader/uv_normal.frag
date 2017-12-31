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
    vec3 direction;
    int onoff; // == 0 or 1
};
uniform vec3 lightdirection1;
uniform vec3 lightdirection2;
uniform vec3 lightdirection3;
uniform vec3 lightdirection4;
uniform vec3 lightdirection5;
uniform vec3 lightcolor1;
uniform vec3 lightcolor2;
uniform vec3 lightcolor3;
uniform vec3 lightcolor4;
uniform vec3 lightcolor5;
uniform int onoff1; uniform int onoff2;
uniform int onoff3; uniform int onoff4; uniform int onoff5;
lightSource light0 = lightSource(
    lightcolor1,    // color
    lightdirection1,      // direction
    onoff1
);
lightSource light1 = lightSource(
    lightcolor2,    // color
    lightdirection2,      // direction
    onoff2
);
lightSource light2 = lightSource(
    lightcolor3,    // color
    lightdirection3,      // direction
    onoff3
);
lightSource light3 = lightSource(
    lightcolor4,    // color
    lightdirection4,      // direction
    onoff4
);
lightSource light4 = lightSource(
    lightcolor5,    // color
    lightdirection5,      // direction
    onoff5
);
lightSource lights[numberoflights];
///////////////////////////////////////////////////////////////////////////////
in vec3 o_normal;
in vec3 o_lightdir;
in vec3 o_vertex;
in vec4 o_color;
in vec2 o_uv;
flat in uvec2 o_id;

out vec4 fragment_color;
out uvec2 fragment_groupid;

const float ALIASING_CONST = 0.70710678118654757;

float aastep(float threshold1, float threshold2, float value) {
    float afwidth = length(vec2(dFdx(value), dFdy(value))) * ALIASING_CONST;
    return smoothstep(threshold1-afwidth, threshold1+afwidth, value)-smoothstep(threshold2-afwidth, threshold2+afwidth, value);
}

const float thickness = 0.01;
float square(vec2 uv)
{
    float xmin = aastep(-0.1, thickness, uv.x);
    float xmax = aastep(1.0-thickness, 1.01, uv.x);
    float ymin = aastep(-0.01, 0.0+thickness, uv.y);
    float ymax = aastep(1.0-thickness, 1.01, uv.y);
	return  xmin +
            xmax +
            ((1-xmin)*(1-xmax))*ymin +
            ((1-xmin)*(1-xmax))*ymax;
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
            vec3 Ldir = normalize(vec3(lights[index].direction));
            float cosTheta = clamp(dot(Ldir, N), 0, 1);
            vec3 R = normalize(Ldir + V);
            float cosAlpha = clamp(dot(R, N), 0, 1);

            vec3 diffuseReflection = material[1] * vec3(lights[index].color) *
                                     cosTheta * color;
            vec3 specularcolor = (1 - material[3]) * vec3(lights[index].color) +
                                  material[3] * vec3(1);
            vec3 specularReflection =  material[2] * vec3(specularcolor) *
                                       pow(cosAlpha, shininess);
            totalLighting = totalLighting +  diffuseReflection + specularReflection;
        }
    }
    return totalLighting;
}

void main(){
    vec3 L      	= normalize(o_lightdir);
    vec3 N 			= normalize(o_normal);
    vec3 f_color    = mix(vec3(0,0,1), vec3(1), square(o_uv));
    //vec3 light1 	= blinnphong(N, o_vertex, L, f_color);
    //vec3 light2 	= blinnphong(N, o_vertex, -L,f_color);
    //fragment_color 	= vec4(light1+light2*0.4, 1.0);
    vec3 light1 	= blinnphong(N, o_vertex, f_color);
    fragment_color 	= vec4(light1, 1.0);
    if(fragment_color.a > 0.0)
        fragment_groupid = o_id;
}
