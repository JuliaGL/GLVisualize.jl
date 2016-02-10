using Colors, GLVisualize

if !isdefined(:runtests)
    window = glscreen()
end
const not_animated = true
using Gadfly, GLVisualize.ComposeBackend

gl_backend = ComposeBackend.GLVisualizeBackend(window)

p = plot(x=1:100, y=2.^rand(100),
     Scale.y_sqrt, Geom.point, Geom.smooth,
     Guide.xlabel("Stimulus"), Guide.ylabel("Response"), Guide.title("Cat Training"))

draw(gl_backend, p)

if !isdefined(:runtests)
renderloop(window)
end
