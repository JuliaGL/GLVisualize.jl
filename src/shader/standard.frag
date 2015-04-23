{{GLSL_VERSION}}

in vec3 o_normal;
in vec3 o_lightdir;
in vec3 o_vertex;
in vec4 o_color;

out vec4 fragment_color;

vec3 blinnphong(vec3 N, vec3 V, vec3 L, vec3 color)
{
    float diff_coeff = max(dot(L,N), 0.0);

    // specular coefficient
    vec3 H = normalize(L+V);
    
    float spec_coeff = pow(max(dot(H,N), 0.0), 10.0);
    if (diff_coeff <= 0.0)
        spec_coeff = 0.0;

    // final lighting model
    return  vec3(
            vec3(0.1)  * vec3(0.2)  +
            vec3(0.9)  * color * diff_coeff);
}


void main(){
    vec3 L      	= normalize(o_lightdir);
    vec3 N 			= normalize(o_normal);
    vec3 light1 	= blinnphong(N, o_vertex, L, o_color.rgb);
    vec3 light2 	= blinnphong(N, o_vertex, -L, o_color.rgb);
    fragment_color 	= vec4(light1+light2*0.5, o_color.a);
}
