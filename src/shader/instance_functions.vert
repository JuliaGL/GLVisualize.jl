mat4 getmodelmatrix(vec3 xyz, vec3 scale)
{
   return mat4(
      vec4(scale.x, 0, 0, 0),
      vec4(0, scale.y, 0, 0),
      vec4(0, 0, scale.z, 0),
      vec4(xyz, 1));
}

vec2 getuv(ivec2 texdim, int index)
{
  float x = float(texdim.x);
  float y = float(texdim.y);
  float i = float(index);

  float u = float((index % texdim.x)) / x;
  float v = (i / y) / y;
  return vec2(u,v);
}


vec2 stretch(vec2 uv, vec2 from, vec2 to)
 {
   return from + (uv * (to - from));
 }
vec3 getxy(vec3 uv, vec3 from, vec3 to)
 {
   return from + (uv * (to - from));
 }

float rangewidth(vec3 range)
{
  return abs(range.x - range.z)/range.y;
}
float maptogridcoordinates(int index, vec3 range)
{
  return range.x + float((index % int(rangewidth(range) - range.x )));
}