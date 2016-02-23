using Colors, GLVisualize
using GLVisualize.ComposeBackend, Compose

if !isdefined(:runtests)
    window = glscreen()
    composebackend = ComposeBackend.GLVisualizeBackend(window)
end
const static_example = true

p = compose(context(0.0mm, 0.0mm, 200mm, 200mm),
    rectangle([0.25, 0.5, 0.75], [0.25, 0.5, 0.75], [0.1], [0.1]),
    fill([LCHab(92, 10, 77), LCHab(68, 74, 192), LCHab(78, 84, 29)]),
    stroke([LCHab(5, 0, 77),LCHab(5, 77, 77),LCHab(50, 0, 8)]),
    (context(), circle(), fill("bisque")),
    (context(), rectangle(), fill("tomato"))
)
draw(composebackend, p)

if !isdefined(:runtests)
	renderloop(window)
end
