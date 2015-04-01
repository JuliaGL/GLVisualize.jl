{{GLSL_VERSION}}

{{in}} vec3 N;
{{in}} vec3 V;
{{in}} vec4 vert_color;

uniform vec3 light_position;

{{out}} vec4 fragment_color;
{{out}} uvec2 fragment_groupid;


vec3 blinn_phong(vec3 N, vec3 V, vec3 L, vec3 diffuse)
{
    // material properties
    // you might want to put this into a bunch or uniforms
    vec3 Ka = vec3(0.0);
    vec3 Kd = vec3(1.0);
    vec3 Ks = vec3(1.0);
    float shininess = 100.0;

    // diffuse coefficient
    float diff_coeff = max(dot(L,N), 0.0);

    // specular coefficient
    vec3 H = normalize(L+V);
    float spec_coeff = pow(max(dot(H,N), 0.0), shininess);
    if (diff_coeff <= 0.0)
        spec_coeff = 0.0;

    // final lighting model
    return  Ka * vec3(0.1) +
            Kd * diffuse * diff_coeff +
            Ks * vec3(1,0,0) * spec_coeff ;
}


void main(){

    vec3 L = normalize(light_position - V);
    vec3 light1 = blinn_phong(N, V, L, vert_color.rgb);
    vec3 light2 = blinn_phong(N, V, -L, vert_color.rgb);
    fragment_color      = vec4(light1 + light2, vert_color.a);
    fragment_groupid    = uvec2(0,0);
}
