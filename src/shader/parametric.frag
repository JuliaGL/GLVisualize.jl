{{GLSL_VERSION}}

float rand(vec2 co){
	// implementation found at: lumina.sourceforge.net/Tutorials/Noise.html
	return fract(sin(dot(co.xy, vec2(12.9898,78.233))) * 43758.5453);
}

// Put your user defined function here...
{{function}}

uniform float jitter = 1.0;
uniform float thickness = 20; 
uniform int samples = 16; 

in vec2 aa_scale;


float getalpha(vec2 pos) {
	vec2 step = thickness*vec2(aa_scale.x,aa_scale.y)/samples;
	float samples = float(samples);
	int count = 0;
	int mysamples = 0;
	for (float i = 0.0; i < samples; i++) {
		for (float  j = 0.0;j < samples; j++) {
			if (i*i+j*j>samples*samples) continue;
			mysamples++;
			float ii = i + jitter*rand(vec2(pos.x + i*step.x,pos.y + j*step.y));
			float jj = j + jitter*rand(vec2(pos.y + i*step.x,pos.x + j*step.y));
			float f = function(pos.x+ ii*step.x)-(pos.y+ jj*step.y);
			count += (f>0.) ? 1 : -1;
		}
	}
	if (abs(count)!=mysamples) return 1-abs(float(count))/float(mysamples);
	return 0.0;
}


in vec2 o_uv;
out vec4 fragment_color;
uniform vec4 color;
void main()
{
	fragment_color = vec4(color.rgb, color.a*getalpha(vec2(o_uv.x*5, o_uv.y)));
}


/*
//note: shadertoy-pluggable, http://www.iquilezles.org/apps/shadertoy/
 
#ifdef GL_ES
precision highp float;
#endif
 
uniform float time;
uniform vec2 resolution;
 
float aspect = resolution.x / resolution.y;
 
float function( float x ) {
  return sin(x*x*x)*sin(x);
//  return sin(x*x*x)*sin(x) + 0.1*sin(x*x);
//  return sin(x);
}
 
//note: does one sample per x, thresholds on distance in y
float discreteEval( vec2 uv ) {
  const float threshold = 0.015;
  float x = uv.x;
  float fx = function( x );
  float dist = abs( uv.y - fx );
  float hit = step( dist, threshold );
  return hit;
}
 
//note: samples graph by checking multiple samples being above / below function
//original from http://blog.hvidtfeldts.net/index.php/2011/07/plotting-high-frequency-functions-using-a-gpu/
float stochEval( vec2 uv ) {
  const int samples = 255; //note: on AMD requires 255+ samples, should be ~50
  const float fsamples = float(samples);
  vec2 maxdist = 0.075 * vec2( aspect, 1.0 );
  vec2 stepsize = maxdist / vec2(samples);
  float count = 0.0;
  vec2 initial_offset = - 0.5 * fsamples * stepsize;
  uv += initial_offset;
  for ( int ii = 0; ii<samples; ii++ ) {
    float i = float(ii);
    float fx = function( uv.x + i*stepsize.x );
    for ( int jj = 0; jj<samples; jj++ ) {
      float j = float(jj);
      float diff =  fx - float(uv.y + j*stepsize.y);
      count = count + step(0.0, diff) * 2.0 - 1.0;
    }
  }
  return 1.0 - abs( count ) / float(samples*samples);
}
 
//note: averages distances over multiple samples along x, result is identical to superEval
float distAvgEval( vec2 uv ) {
  const int samples = 255; //note: on AMD requires 255+ samples, should be ~50
  const float fsamples = float(samples);
  vec2 maxdist = 0.075 * vec2( aspect, 1.0 );
  vec2 halfmaxdist = 0.5 * maxdist;
  float stepsize = maxdist.x / fsamples;
  float initial_offset_x = -0.5*fsamples * stepsize;
  uv.x += initial_offset_x;
  float hit = 0.0;
  for( int i=0; i<samples; ++i ) {
    float x = uv.x + stepsize * float(i);
    float y = uv.y;
    float fx = function( x );
    float dist = ( y - fx );
    float vt = clamp( dist / halfmaxdist.y -1.0, -1.0, 1.0 );
    hit += vt;
  }
  return 1.0 - abs(hit) / fsamples;
}
 
//note: does multiple thresholded samples
float proxyEval( vec2 uv ) {
  const int samples = 255; //note: on AMD requires 255+ samples, should be ~50
  const float fsamples = float(samples);
  vec2 maxdist = vec2(0.05) * vec2( aspect, 1.0 );
  vec2 halfmaxdist = vec2(0.5) * maxdist;
  float stepsize = maxdist.x / fsamples;
  float initial_offset_x = -0.5 * fsamples * stepsize;
  uv.x += initial_offset_x;
  float hit = 0.0;
  for( int i=0; i<samples; ++i ) {
    float x = uv.x + stepsize * float(i);
    float y = uv.y;
    float fx = function( x );
    float dist = abs( y - fx );
    hit += step( dist, halfmaxdist.y );
  }
  const float arbitraryFactor = 3.5; //note: to increase intensity
  const float arbitraryExp = 0.95;
  return arbitraryFactor * pow( hit / fsamples, arbitraryExp );
}
 
 
void main(void)
{
  vec2 uv_norm = gl_FragCoord.xy / resolution.xy;
  vec4 dim = vec4( -2.0, 12.0, -3.0, 3.0 );
  uv_norm = (uv_norm ) * ( dim.yw - dim.xz ) + dim.xz;
 
  //float hitStoch = stochEval( uv_norm - vec2(0,2) );
  float hitDiscr = discreteEval( uv_norm  + vec2(0,2) );
  float hitProximity = proxyEval( uv_norm - vec2(0,2) );
  float hitDistAvgStoch = distAvgEval( uv_norm - vec2(0,0) );
 
 gl_FragColor = vec4( hitDistAvgStoch
                    , 0.8*hitProximity + 0.5*hitDiscr
                    , hitDiscr + 0.2*hitProximity
                    , 1.0);
}
clone this paste RAW Paste Data
*/