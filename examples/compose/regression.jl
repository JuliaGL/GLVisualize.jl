using GLVisualize.ComposeBackend, Gadfly
using Colors, GLVisualize

if !isdefined(:runtests)
    window = glscreen()
    composebackend = ComposeBackend.GLVisualizeBackend(window)
end

const static_example = true


using Distributions
x1 = rand(40)
y1 = 4.*x1 .+ 2 .+randn(40)
x2 = rand(40)
y2 = -6.*x2 .+ 3 .+ randn(40)
x  = [x1;x2]
y  = [y1;y2]
col = [fill("Slope 4",40); fill("Slope -6",40)]
p = plot(x=x,y=y,colour=col, Geom.point, Geom.smooth(method=:lm))

draw(composebackend, p)

if !isdefined(:runtests)
	renderloop(window)
end
