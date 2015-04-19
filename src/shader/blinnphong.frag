vec4 blinnphong(vec3 N, vec3 V, vec3 L, vec3 light[4], vec4 mat[4])
{
    float diff_coeff = max(dot(L,N), 0.0);
    // specular coefficient
    vec3 H = normalize(L+V);
    
    float spec_coeff = pow(max(dot(H,N), 0.0), mat[specular_exponent].x);
    if (diff_coeff <= 0.0)
        spec_coeff = 0.0;

    // final lighting model
    return  vec4(
            light[ambient]  * mat[ambient].rgb  +
            light[diffuse]  * mat[diffuse].rgb  * diff_coeff +
            light[specular] * mat[specular].rgb * spec_coeff, 
            1);
}