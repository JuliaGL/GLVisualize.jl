{{GLSL_VERSION}}
{{GLSL_EXTENSIONS}}

in vec3 vertex;
in vec3 normal; 
in vec2 uv;

const uint material_id = 0;

uniform sampler2D color;
uniform sampler2D intensity;
uniform sampler2D intensity;
uniform sampler1D color_ramp;
uniform sampler2D particles;
uniform sampler2D material_map; //4xN texture, with diffuse/etc at the position const diffuse/etc


uniform Cube    position;
uniform Plane   position;
uniform Vec3    position;
uniform Vec2    position;

uniform Sampler1D   color_ramp;
uniform Float       intensity;

uniform Vec4 color;



uniform mat4 projection, view, model;

uniform vec3 light[4];

const int diffuse           = 0;
const int ambient           = 1;
const int specular          = 2;
const int specular_exponent = 3;
const int position          = 3;


// data for fragment shader
out FragmentData {
    vec3 o_normal;
    vec3 o_lightdir;
    vec3 o_vertex;
    vec2 o_uv;
    vec4 o_material[4];
    flat uint o_material_id;
};


void render(vec3 vertex, vec3 normal, vec2 uv,  mat4 model, vec4 material[4], uint material_id)
{
    mat3 normalmatrix       = mat3(view*model); // shoudl really be done on the cpu
    vec4 position_camspace  = view * model * vec4(vertex,  1);
    // normal in world space
    o_normal                = normalize(normalmatrix * normal);
    // direction to light
    o_lightdir              = normalize(light[position] - position_camspace.xyz);
    // direction to camera
    o_vertex                = -position_camspace.xyz;
    o_material              = material;
    o_material_id           = material_id;
    // texture coordinates to fragment shader
    o_uv                    = vec2(uv.x, 1-uv.y);
    // screen space coordinates of the vertex
    gl_Position             = projection * position_camspace; 
}




void main(){
    int  width      = textureSize(particles, 0).x;
    vec4 position   = texelFetch(particles, ivec2(gl_InstanceID%width, gl_InstanceID/width), 0);
    float intensity = position.a;

    vec4[4] material;
    material[diffuse]           = vec4(texture(color_ramp, intensity).rgb, 0.1);
    material[ambient]           = texelFetch(material_map, ivec2(int(material_id), ambient), 0);
    material[specular]          = texelFetch(material_map, ivec2(int(material_id), specular), 0);
    material[specular_exponent] = texelFetch(material_map, ivec2(int(material_id), specular_exponent), 0);

    render((vertex*0.1)+position.xyz, 
        normal, 
        uv, 
        model, 
        material, material_id);
}