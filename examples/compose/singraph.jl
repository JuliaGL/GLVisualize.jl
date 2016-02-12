using Colors, GLVisualize
using Gadfly, GLVisualize.ComposeBackend

if !isdefined(:runtests)
    window = glscreen()
    composebackend = ComposeBackend.GLVisualizeBackend(window)
end
const static_example = true


p = plot([sin, cos], 0, 25)

draw(composebackend, p)
if !isdefined(:runtests)
renderloop(window)
end
