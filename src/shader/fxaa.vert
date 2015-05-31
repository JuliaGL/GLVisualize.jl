//precision mediump float;
{{GLSL_VERSION}}

//texcoords computed in vertex step
//to avoid dependent texture reads
out vec2 v_rgbNW;
out vec2 v_rgbNE;
out vec2 v_rgbSW;
out vec2 v_rgbSE;
out vec2 v_rgbM;

//incoming Position attribute from our SpriteBatch
in vec2 vertices;
in vec2 texturecoordinates;

//uniforms from sprite batch
out vec2 vTexCoord0;

//a resolution for our optimized shader
uniform vec2 resolution;


void texcoords(vec2 fragCoord, vec2 resolution,
			out vec2 v_rgbNW, out vec2 v_rgbNE,
			out vec2 v_rgbSW, out vec2 v_rgbSE,
			out vec2 v_rgbM) {
	vec2 inverseVP = 1.0 / resolution.xy;
	v_rgbNW = (fragCoord + vec2(-1.0, -1.0)) * inverseVP;
	v_rgbNE = (fragCoord + vec2(1.0, -1.0)) * inverseVP;
	v_rgbSW = (fragCoord + vec2(-1.0, 1.0)) * inverseVP;
	v_rgbSE = (fragCoord + vec2(1.0, 1.0)) * inverseVP;
	v_rgbM = vec2(fragCoord * inverseVP);
}

void main(void) {
   gl_Position 	= vec4(vertices.x, vertices.y, 0.0, 1.0);
   vTexCoord0 	= texturecoordinates;
   //compute the texture coords and send them to varyings
   vec2 fragCoord = vTexCoord0 * resolution;
   texcoords(fragCoord, resolution, v_rgbNW, v_rgbNE, v_rgbSW, v_rgbSE, v_rgbM);
}