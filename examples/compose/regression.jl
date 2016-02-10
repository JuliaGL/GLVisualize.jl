if !isdefined(:runtests)
    using Colors, GLVisualize
    window = glscreen()
end

const not_animated = true
using GLVisualize.ComposeBackend, Gadfly
gl_backend = ComposeBackend.GLVisualizeBackend(window)


using Distributions
x1 = rand(40)
y1 = 4.*x1 .+ 2 .+randn(40)
x2 = rand(40)
y2 = -6.*x2 .+ 3 .+ randn(40)
x  = [x1;x2]
y  = [y1;y2]
col = [fill("Slope 4",40); fill("Slope -6",40)]
p = plot(x=x,y=y,colour=col, Geom.point, Geom.smooth(method=:lm))

draw(gl_backend, p)

if !isdefined(:runtests)
	renderloop(window)
end
