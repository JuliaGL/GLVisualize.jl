if !isdefined(:runtests)
    using Colors, GLVisualize
    window = glscreen()
end
const not_animated = true
using Gadfly, GLVisualize.ComposeBackend

gl_backend = ComposeBackend.GLVisualizeBackend(window)

p = plot([sin, cos], 0, 25)

draw(gl_backend, p)
if !isdefined(:runtests)
renderloop(window)
end
