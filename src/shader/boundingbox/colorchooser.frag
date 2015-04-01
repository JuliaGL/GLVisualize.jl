{{GLSL_VERSION}}

{{out}} vec4 minbuffer;
{{out}} vec4 maxbuffer;


vec3 hsv2rgb(vec3 c)
{
    vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

vec3 rgb2hsv(vec3 c)
{
    vec4 K = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
    vec4 p = c.g < c.b ? vec4(c.bg, K.wz) : vec4(c.gb, K.xy);
    vec4 q = c.r < p.x ? vec4(p.xyw, c.r) : vec4(c.r, p.yzx);
    float d = q.x - min(q.w, q.y);
    float e = 1.0e-10;
    return vec3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
}

const float floatmax = 99999999999999999999999999999999999999.0; //Todo fill in correct floatmax

{{in}} vec2 frag_uv;
{{in}} vec4 V;
uniform vec2 middle;
uniform vec4 color;

uniform float swatchsize;
uniform vec4 border_color;
uniform float border_size;
uniform bool hover;
uniform bool hue_saturation;
uniform bool brightness_transparency;

uniform float antialiasing_value;


void main(){
	vec3 hsv 			= rgb2hsv(color.rgb);
	vec4 result_color 	= vec4(0);
	vec2 radius_vec 	= middle - frag_uv;
	float radius 		= length(radius_vec);
	float swatchborder  = swatchsize + border_size;
    float avalue        = 0.001;


	if(radius < swatchsize  - (avalue / 2.0))
	{
		result_color      = color;
	}else if( (radius >= swatchsize  - (avalue / 2.0)) && radius < swatchborder)
	{
        result_color = border_color;
        if(radius <= swatchsize + (avalue / 2.0))
        {
            float interpolationvalue = radius - (swatchsize  - (avalue / 2.0));
            interpolationvalue /= avalue;
            result_color = mix(color, border_color, interpolationvalue);

        }else if(radius >= swatchborder - avalue)
        {
            float interpolationvalue = radius - (swatchborder - avalue);
            interpolationvalue /= avalue;
            result_color = vec4(border_color.rgb, interpolationvalue);
        }

	}
    else if(hover)
	{
		// start from border of switch
		float normed_distfromborder = radius - swatchborder;
		// norm range between 0-1
		normed_distfromborder 		= normed_distfromborder / (1.0-swatchborder);
		// account for radius vs diameter
		normed_distfromborder 	   *= 3;

		float alpha = smoothstep(0.0, 0.05, 1-normed_distfromborder);

		if(hue_saturation)
		{	
			// for the saturation calculation, we want to get back the sign of the xplane
			// polar coordinates for hue, just taking the fraction part, to keep it between 0-1
			float hue = fract(hsv.x + atan(abs(radius_vec.x), abs(radius_vec.y)) / 3.0);

            float yradius = radius_vec.y;
            float xradius = radius_vec.x;
            if(abs(xradius) < swatchsize)
            {
                result_color = vec4(hsv2rgb(vec3(hsv.x, clamp(hsv.y - yradius, 0.0, 1.0), hsv.z)),alpha);

            }else if(abs(xradius) < swatchborder)
            {
                result_color = vec4(0);
            }else
            {
                float hue = fract((hsv.x + atan(radius_vec.x, radius_vec.y))/5);
                result_color = vec4(hsv2rgb(vec3(hsv.x + normed_distfromborder/5, hsv.yz)), alpha);
            }
		}
		else if(brightness_transparency)
		{
			// brightness gets varied on an y column, with the width of the color swatch
            float yradius = radius_vec.y;
			float xradius = radius_vec.x;
			if(abs(xradius) < swatchsize)
			{
				
				float brightness = hsv.z;
                if(radius_vec.y < 0.0)
                {
                    normed_distfromborder = -normed_distfromborder;
                }
				brightness = clamp(brightness - normed_distfromborder, 0.0, 1.0);
				result_color = vec4(hsv2rgb(vec3(hsv.xy, brightness)), alpha);
			}else if(abs(xradius) < swatchborder)
            {
                result_color = vec4(0);
            }else
			{
				result_color = vec4(hsv2rgb(hsv), clamp(1-(-xradius), 0.0, alpha));
			}
		}
		
	}
    
  	if (result_color.a > 0.0)
	{
		minbuffer = -V;
		maxbuffer = V;
	}else{
		minbuffer = vec4(0);
		maxbuffer = vec4(0);
	}
}


