using Colors, GLVisualize
using Gadfly, GLVisualize.ComposeBackend

if !isdefined(:runtests)
    window = glscreen()
end
const not_animated = true

gl_backend = ComposeBackend.GLVisualizeBackend(window)

p = plot([sin, cos], 0, 25)

draw(gl_backend, p)
if !isdefined(:runtests)
renderloop(window)
end
