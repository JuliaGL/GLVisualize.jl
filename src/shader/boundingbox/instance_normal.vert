{{GLSL_VERSION}}
{{GLSL_EXTENSIONS}}

{{vertex_type}} vertex;
{{normal_vector_type}} normal_vector; // normal might not be an uniform, whereas the other will be allways uniforms
{{offset_type}} offset;	//offset for texture look up. Needed to get neighbouring vertexes, when rendering the surface


{{xrange_type}} xrange;	
{{yrange_type}} yrange; 	
{{z_type}} z;	
		
{{xscale_type}} xscale;	
{{yscale_type}} yscale;		
{{zscale_type}} zscale;		
{{color_type}} color;

uniform vec2 texdimension;

uniform mat3 normalmatrix;
uniform mat4 modelmatrix;
uniform mat4 projection, view;

{{out}} vec3 N;
{{out}} vec3 V;
{{out}} vec4 vert_color;

{{instance_functions}} //It's rather a bad idea, but I outsourced the functions to another file

vec3 getnormal(sampler2D zvalues, vec2 uv)
{   
    float weps = 1.0/textureSize(zvalues,0).x;
    float heps = 1.0/textureSize(zvalues,0).y;

    vec2 off1 = uv + vec2(-weps,0);
    vec2 off2 = uv + vec2(0, heps);
    vec2 off3 = uv + vec2(weps, 0);
	vec2 off4 = uv + vec2(0,-heps);

    vec3 s0 = vec3(uv, texture(zvalues, uv).x);

    vec3 s1 = vec3((off1), texture(zvalues, off1).x);
    vec3 s2 = vec3((off2), texture(zvalues, off2).x);
    vec3 s3 = vec3((off3), texture(zvalues, off3).x);
    vec3 s4 = vec3((off4), texture(zvalues, off4).x);

    return normalize(
        cross(s0-s1, s0-s2) +
        cross(s0-s2, s0-s3) +
        cross(s0-s3, s0-s4) +
        cross(s0-s4, s0-s1) 
        );
}
vec3 getnormal(float zvalues, vec2 uv)
{
    return normal_vector;
}

vec2 getcoordinate(sampler2D xvalues, sampler2D yvalues, vec2 uv)
{
	return vec2(texture(xvalues, uv).x, texture(yvalues, uv).x);
}
vec2 getcoordinate(vec2 xrange, vec2 yrange, vec2 uv)
{
	vec2 from = vec2(xrange.x, yrange.x);
	vec2 to   = vec2(xrange.y, yrange.y);
	return from + (uv * (to - from));
}
vec2 getuv(vec2 texdim, int index, vec2 offset)
{
  float u = float((index % int(texdim.x)));
  float v = float((index / int(texdim.x)));
  return (vec2(u,v) + offset) / (texdim+1);
}

mat3 rotation(vec3 X, vec3 Y)  
{  
    mat3 M;  
    M[0] = normalize(X);  
    M[2] = normalize(cross(X,Y));
    M[1] = normalize(cross(M[2], X));  
    return M;
}


void main(){

	vec3  xyz, scale, normal, vert;
	vec2 uv = getuv(texdimension, gl_InstanceID, offset);
	xyz.xy 	= getcoordinate(xrange, yrange, uv);
	xyz.z 	= {{z_calculation}}
	
    scale.x = {{xscale_calculation}}
    scale.y = {{yscale_calculation}}
	scale.z = {{zscale_calculation}}
	
    vec3 surfnormal = getnormal(z, uv);

    normal = normal_vector;

    vert_color = vec4(surfnormal,1);


    N = normalize(normalmatrix*normal);
    V = vec3(view  * vec4(xyz, 1.0));
    float linestartend = {{vertex_calculation}}

    if( linestartend == 1.0)
    {
        gl_Position = projection * view * modelmatrix * vec4(xyz, 1.0);
    }
    else
    {
        gl_Position = projection * view * modelmatrix * vec4(xyz + surfnormal*0.1, 1.0);
    }

}