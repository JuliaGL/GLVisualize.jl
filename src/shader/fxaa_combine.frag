{{GLSL_VERSION}}
//precision mediump float;

//texcoords computed in vertex step
//to avoid dependent texture reads
in vec2 v_rgbNW;
in vec2 v_rgbNE;
in vec2 v_rgbSW;
in vec2 v_rgbSE;
in vec2 v_rgbM;

//make sure to have a resolution uniform set to the screen size
uniform vec2 resolution;

//some stuff needed for kami-batch
in vec2 vTexCoord0; 

uniform sampler2D u_texture0;

//import the fxaa function
vec4 fxaa(sampler2D tex, vec2 fragCoord, vec2 resolution,
            vec2 v_rgbNW, vec2 v_rgbNE, 
            vec2 v_rgbSW, vec2 v_rgbSE, 
            vec2 v_rgbM);

out vec4 fragment_color;

void main() {
    //can also use gl_FragCoord.xy
    vec2 fragCoord 	= vTexCoord0 * resolution; 
    fragment_color 	= texture(u_texture0, vTexCoord0);
    //fragment_color 	= fxaa(u_texture0, fragCoord, resolution, v_rgbNW, v_rgbNE, v_rgbSW, v_rgbSE, v_rgbM); // uncomment for anti aliasing
}