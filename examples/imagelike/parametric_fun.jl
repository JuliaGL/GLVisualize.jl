using GLVisualize, GLAbstraction

if !isdefined(:runtests)
	window = glscreen()
    timesignal = loop(linspace(0f0,1f0,360))
end

# create a glsl fragment shader
parametric_func = frag"""
    uniform float arg1; // you can add arbitrary uniforms and supply them via the keyword args
    float function(float x) {
     return arg1*sin(1/tan(x));
   }
"""
# view the function on a 1700x800 pixel plane
paremetric = visualize(parametric_func, arg1=timesignal, dimensions=(1700, 800))
view(paremetric, window, camera=:orthographic_pixel)

if !isdefined(:runtests)
	renderloop(window)
end
