{{GLSL_VERSION}}

// uniforms
uniform sampler3D u_volumetex;
uniform vec3      u_shape;
uniform float     u_threshold;
uniform float     u_relative_step_size;
//varyings
in vec3 v_position;
in vec4 v_nearpos;
in vec4 v_farpos;
// uniforms for lighting. Hard coded until we figure out how to do lights

// global holding view direction in local coordinates
vec3 view_ray;
out vec4 frag_color;
void main() {
    vec3 farpos  = v_farpos.xyz  / v_farpos.w;
    vec3 nearpos = v_nearpos.xyz / v_nearpos.w;
    
    // Calculate unit vector pointing in the view direction through this 
    // fragment.
    view_ray = normalize(farpos.xyz - nearpos.xyz);
    
    // Compute the distance to the front surface or near clipping plane
    float distance = dot(nearpos-v_position, view_ray);
    distance = max(distance, min((-0.5 - v_position.x) / view_ray.x, 
                            (u_shape.x - 0.5 - v_position.x) / view_ray.x));
    distance = max(distance, min((-0.5 - v_position.y) / view_ray.y, 
                            (u_shape.y - 0.5 - v_position.y) / view_ray.y));
    distance = max(distance, min((-0.5 - v_position.z) / view_ray.z, 
                            (u_shape.z - 0.5 - v_position.z) / view_ray.z));
    
    // Now we have the starting position on the front surface
    vec3 front = v_position + view_ray * distance;
    
    // Decide how many steps to take
    int nsteps = int(-distance / 0.5 + 0.5);
    frag_color = vec4(front, 1.0);

}
