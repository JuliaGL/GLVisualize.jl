{{GLSL_VERSION}}

{{in}} vec4 vertpos;
{{out}} vec4 fragment_color;
{{out}} uvec2 fragment_groupid;

uniform sampler2D frontface1;
uniform sampler2D backface1;

uniform sampler2D backface2;
uniform sampler2D frontface2;


uniform sampler3D volume_tex;

uniform float algorithm;
uniform float stepsize;
uniform vec3 light_position;

uniform float isovalue;

uniform vec3 color;



vec3 gennormal(vec3 uvw, vec3 gradient_delta)
{
    vec3 a,b;
    a.x = texture(volume_tex, uvw -vec3(gradient_delta.x,0.0,0.0) ).r;
    b.x = texture(volume_tex, uvw +vec3(gradient_delta.x,0.0,0.0) ).r;
    a.y = texture(volume_tex, uvw -vec3(0.0,gradient_delta.y,0.0) ).r;
    b.y = texture(volume_tex, uvw +vec3(0.0,gradient_delta.y,0.0) ).r;
    a.z = texture(volume_tex, uvw -vec3(0.0,0.0,gradient_delta.z) ).r;
    b.z = texture(volume_tex, uvw +vec3(0.0,0.0,gradient_delta.z) ).r;
    return normalize(a - b);
}
vec3 blinn_phong(vec3 N, vec3 V, vec3 L, vec3 diffuse)
{
    // material properties
    vec3 Ka = vec3(0.1);
    vec3 Kd = vec3(1.0, 1.0, 1.0);
    vec3 Ks = vec3(1.0, 1.0, 1.0);
    float shininess = 50.0;

    // diffuse coefficient
    float diff_coeff = max(dot(L,N),0.0);

    // specular coefficient
    vec3 H = normalize(L+V);
    float spec_coeff = pow(max(dot(H,N), 0.0), shininess);
    if (diff_coeff <= 0.0)
        spec_coeff = 0.0;

    // final lighting model
    return  Ka * vec3(0.8) +
            Kd * diffuse  * diff_coeff +
            Ks * vec3(0.8) * spec_coeff ;
}


vec4 isosurface(vec3 front, vec3 back, float stepsize)
{
  vec3  dir            = vec3(back - front);
  float lengthdir      = length(dir);
  vec3  stepsize_dir   = normalize(dir) * stepsize;
  float colorsample    = 0.0;
  vec3  start          = front;
  float length_acc     = 0.0;
  vec4  result         = vec4(0);
  int i = 0;
  for(i; i < 1000; i++)
  {
    if(length_acc >= lengthdir)
    {
      break;
    }
    colorsample = texture(volume_tex, start).r;
    if(abs(colorsample - isovalue) < 0.05)
    {
      vec3 N = gennormal(start, vec3(stepsize));
      vec3 L = normalize(light_position - start);
      result = vec4(blinn_phong(N, start, L, color), 1.0);
      break;
    }
    start        += stepsize_dir;
    length_acc   += stepsize;
  }
  return result;
}
vec4 mip(vec3 front, vec3 back, float stepsize)
{
  vec3  dir            = vec3(back - front);
  float lengthdir      = length(dir);
  vec3  stepsize_dir   = normalize(dir) * stepsize;
  float colorsample    = 0.0;
  vec3  start          = front;
  float length_acc     = 0.0;
  float maximum        = 0.0;
  int i = 0;
  for(i; i < 1000; i++)
  {
    if(length_acc >= lengthdir)
    {
      break;
    }
    colorsample = texture(volume_tex, start).r;
    if(maximum < colorsample)
    {
      //vec3 N = gennormal(start, vec3(stepsize));
      //vec3 L =  normalize(light_position - start);
      maximum = colorsample;
    }
    start        += stepsize_dir;
    length_acc   += stepsize;
  }
  return vec4(maximum);
}
void main()
{
  //get vertex position in screen space
  vec2 texc            = ((vertpos.xy / vertpos.w) + 1) / 2;

  vec4 aback           = texture(backface1, texc);
  vec4 bback           = texture(backface2, texc);

  vec4 afront          = texture(frontface1, texc);
  vec4 bfront          = texture(frontface2, texc);


  vec4 result_color               = vec4(0);

  bool aback_infront_bback        = length(bback.rgb  - aback.rgb)  >= 0.0;
  bool bfront_infront_afront      = length(bfront.rgb - afront.rgb) <= 0.0;
  bool not_bfront_infront_afront  = length(bfront.rgb - afront.rgb) >= 0.0;
  bool afront_infront_bback       = length(bback.rgb  - afront.rgb) >= 0.0;
  bool aback_infront_bfront       = length(bfront.rgb - aback.rgb)  >= 0.0;

  vec4 front = afront;
  vec4 back  = aback;

  if(
    !aback_infront_bback && //if A's backface is behind B's backface
     bfront_infront_afront // and B sticks out of A, we cutted the whole volume
  )
  {
    front = vec4(0);
    back  = vec4(0);
  }
  else if(bfront.a != 0.0) // only modify, if B is present
  {
    if(
      aback_infront_bback &&
      bfront_infront_afront && //if volume B has a frontface outside A
      afront_infront_bback
    ){
      front = bback;
    }
    if(
      aback_infront_bfront &&
      not_bfront_infront_afront
    ){
      back = bfront;
    }
  }
  if(front.a != 0.0)
  {
    if(algorithm==1.0)
    {
      result_color = mip(afront.rgb, aback.rgb, stepsize);
    }else  
    {
      result_color = isosurface(afront.rgb, aback.rgb, stepsize);
    }
  }
  fragment_color = result_color;
  fragment_groupid = uvec2(0);
}
