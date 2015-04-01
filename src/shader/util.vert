
vec3 stretch(vec3 uvw, vec3 from, vec3 to)
 {
   return from + (uvw * (to - from));
 }
vec2 stretch(vec2 uv, vec2 from, vec2 to)
 {
   return from + (uv * (to - from));
 }
 float stretch(float uv, float from, float to)
 {
   return from + (uv * (to - from));
 }

const vec3 up = vec3(0,0,1);
mat4 rotation(vec3 direction)
{
    mat4 viewMatrix = mat4(1.0);

    if(direction == up)
    {
        return viewMatrix;
    }
    viewMatrix[0] = vec4(normalize(direction), 0);
    viewMatrix[1] = vec4(normalize(cross(up, viewMatrix[0].xyz)), 0);
    viewMatrix[2] = vec4(normalize(cross(viewMatrix[0].xyz, viewMatrix[1].xyz)), 0);
    
    return viewMatrix;
}
mat4 getmodelmatrix(vec3 xyz, vec3 scale)
{
   return mat4(
      vec4(scale.x, 0, 0, 0),
      vec4(0, scale.y, 0, 0),
      vec4(0, 0, scale.z, 0),
      vec4(xyz, 1));
}

void render(vec3 vertex, vec3 normal, mat4 model, mat4 view, mat4 projection)
{
    mat4 modelview              = view * model;
    mat3 normalmatrix           = mat3(modelview); // shoudl really be done on the cpu
    vec4 position_camspace      = modelview * vec4(vertex,  1);
    vec4 lightposition_camspace = view * vec4(light_position, 1);
    // normal in world space
    o_normal            = normalize(normalmatrix * normal);
    // direction to light
    o_lightdir          = normalize(lightposition_camspace.xyz - position_camspace.xyz);
    // direction to camera
    o_vertex            = -position_camspace.xyz;
    // texture coordinates to fragment shader
    // screen space coordinates of the vertex
    gl_Position  = projection * position_camspace; 
}