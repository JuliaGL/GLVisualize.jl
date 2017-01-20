using GLVisualize, GLAbstraction

if !isdefined(:runtests)
	window = glscreen()
    timesignal = loop(linspace(0f0,1f0,360))
end

description = """
This example shows how you can define a function in the OpenGL shader language,
which will get sampled on the GPU on a per pixel basis.
"""

# create a glsl fragment shader
parametric_shader = """
uniform float arg1; // you can add arbitrary uniforms and supply them via the keyword args
float function(float x) {
    return arg1 * sin(1.0/tan(x));
}
"""
# _view the function on a 1700x800 pixel plane
paremetric = visualize(parametric_shader, :shader, arg1 = timesignal, dimensions = (1700, 800))
_view(paremetric, window, camera=:orthographic_pixel)

if !isdefined(:runtests)
    renderloop(window)
end
