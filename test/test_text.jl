using GeometryTypes, GLAbstraction, ModernGL, GLVisualize, Reactive
using FileIO

include("utf8_example_text.jl")
robj3 = visualize(utf8_example_text)
robj = visualize(robj3[:positions])



push!(GLVisualize.ROOT_SCREEN.renderlist, robj3)
push!(GLVisualize.ROOT_SCREEN.renderlist, robj)
const mouse_hover = lift(first, GLVisualize.SELECTION[:mouse_hover])



glClearColor(1,1,1,1)
renderloop()

