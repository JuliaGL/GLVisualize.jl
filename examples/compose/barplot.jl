using Colors, GLVisualize
using GLVisualize.ComposeBackend, Gadfly, DataFrames, RDatasets

if !isdefined(:runtests)
    window = glscreen()
    composebackend = ComposeBackend.GLVisualizeBackend(window)
end
const static_example = true


p = plot(dataset("car", "SLID"), x="Wages", color="Language", Geom.histogram)

draw(composebackend, p)

if !isdefined(:runtests)
	renderloop(window)
end
