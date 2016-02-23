using Colors, GLVisualize
using Gadfly, GLVisualize.ComposeBackend

if !isdefined(:runtests)
    window = glscreen()
    composebackend = ComposeBackend.GLVisualizeBackend(window)

end
const static_example = true


p = plot(x=1:100, y=2.^rand(100),
     Scale.y_sqrt, Geom.point, Geom.smooth,
     Guide.xlabel("Stimulus"), Guide.ylabel("Response"), Guide.title("Cat Training"))

draw(composebackend, p)

if !isdefined(:runtests)
renderloop(window)
end
