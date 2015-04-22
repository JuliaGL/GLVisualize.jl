{{GLSL_VERSION}}
{{GLSL_EXTENSIONS}}

{{vertex_type}} vertex;
{{normal_type}} normal; // normal might not be an uniform, whereas the other will be allways uniforms
{{offset_type}} offset; //offset for texture look up. Needed to get neighbouring vertexes, when rendering the surface

{{xrange_type}} xrange; 
{{yrange_type}} yrange;
{{z_type}} z;   

{{xscale_type}} xscale; 
{{yscale_type}} yscale; 
{{zscale_type}} zscale; 

{{color_type}} color;

uniform vec2 texdimension;

uniform mat4 projection, view, model;

uniform vec3 light[4];
const int diffuse           = 0;
const int ambient           = 1;
const int specular          = 2;
const int specular_exponent = 3;
const int position          = 3;

uniform sampler3D vectorfield;
uniform sampler1D color_ramp;
uniform sampler2D material_map;

// data for fragment shader
{{out}} vec3 o_normal;
{{out}} vec3 o_lightdir;
{{out}} vec3 o_vertex;
{{out}} vec2 o_uv;
{{out}} vec4 o_material[4];
flat {{out}} uint o_material_id;

{{instance_functions}} //It's rather a bad idea, but I outsourced the functions to another file

bool isinbounds(vec2 uv)
{
	return (uv.x <= 1.0 && uv.y <= 1.0 && uv.x >= 0.0 && uv.y >= 0.0);
}
vec3 getnormal(sampler2D zvalues, vec2 uv, vec3 normal)
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

    return normalize(result + normal); // normal should be zero, but needs to be here, because the dead-code elimanation of GLSL is overly enthusiastic
}

vec3 getnormal(float zvalues, vec2 uv, vec3 normal)
{
    return normal;
}
vec2 getcoordinate(sampler2D xvalues, sampler2D yvalues, vec2 uv)
{
    return vec2(texture(xvalues, uv).x, texture(yvalues, uv).x);
}
vec2 getcoordinate(vec2 xrange, vec2 yrange, vec2 uv)
{
    vec2 from   = vec2(xrange.x, yrange.x);
    vec2 to     = vec2(xrange.y, yrange.y);
    return from + (uv * (to - from));
}
vec2 getuv(vec2 texdim, int index, vec2 offset)
{
    float u = float((index % int(texdim.x)));
    float v = float((index / int(texdim.x)));
    return (vec2(u,v) + offset) / (texdim+1);
}


void render(vec3 vertex, vec3 normal, vec2 uv,  mat4 model, vec4 material[4], uint material_id)
{
    mat4 viewmodel              = view*model;
    mat3 normalmatrix           = mat3(viewmodel); // shoudl really be done on the cpu
    vec4 position_camspace      = viewmodel * vec4(vertex, 1);
    vec4 lightposition_camspace = view * vec4(light[position], 1);
    // normal in world space
    o_normal            = normalize(normalmatrix * normal);
    // direction to light
    o_lightdir          = normalize(lightposition_camspace.xyz - position_camspace.xyz);
    // direction to camera
    o_vertex            = -position_camspace.xyz;
    o_material          = material;
    o_material_id       = material_id;
    // texture coordinates to fragment shader
    o_uv                = vec2(uv.x, 1-uv.y);
    // screen space coordinates of the vertex
    gl_Position         = projection * position_camspace; 
}

void main(){
    vec3 xyz, scale, N, V;

    vec2 uv     = getuv(texdimension, gl_InstanceID, offset);
    xyz.xy      = getcoordinate(xrange, yrange, uv);
    xyz.z       = {{z_calculation}}
    scale.x     = {{xscale_calculation}}
    scale.y     = {{yscale_calculation}}
    scale.z     = {{zscale_calculation}}

    N           = getnormal(z, uv, normal);
    V           = {{vertex_calculation}}

    vec4[4] material;
    material[diffuse]           = {{color_calculation}}
    material[ambient]           = texelFetch(material_map, ivec2(int(material_id), ambient), 0);
    material[specular]          = texelFetch(material_map, ivec2(int(material_id), specular), 0);
    material[specular_exponent] = texelFetch(material_map, ivec2(int(material_id), specular_exponent), 0);

    render(V, N, uv, model * getmodelmatrix(xyz, scale), material);
}