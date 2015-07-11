{{GLSL_VERSION}}

in vec3 vertices;


out vec3 v_position;
out vec4 v_nearpos;
out vec4 v_farpos;

uniform mat4 projection, view, model;

void main() {
    v_position = vertices;
    mat4 projectionview = projection*view;
    mat4 viewi = inverse(projectionview);
    // Project local vertex coordinate to camera position. Then do a step
    // backward (in cam coords) and project back. Voila, we get our ray vector.
    gl_Position     = projectionview * vec4(v_position, 1);
    vec4 pos_in_cam = gl_Position;
    // intersection of ray and near clipping plane (z = -1 in clip coords)
    pos_in_cam.z = -pos_in_cam.w;
    v_nearpos    = viewi*pos_in_cam;
    
    // intersection of ray and far clipping plane (z = +1 in clip coords)
    pos_in_cam.z = pos_in_cam.w;
    v_farpos     = viewi * pos_in_cam;
    
}