using Colors, GLVisualize
using GLVisualize.ComposeBackend, Gadfly, DataFrames, RDatasets

if !isdefined(:runtests)
    window = glscreen()
end
const not_animated = true

gl_backend = ComposeBackend.GLVisualizeBackend(window)

p = plot(dataset("car", "SLID"), x="Wages", color="Language", Geom.histogram)

draw(gl_backend, p)

if !isdefined(:runtests)
	renderloop(window)
end
