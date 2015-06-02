using GeometryTypes, GLAbstraction, ModernGL, GLVisualize
using FileIO

include("utf8_example_text.jl")

robj3 = visualize(utf8_example_text, model=translationmatrix(Vec3(0,-1000,0)))
push!(GLVisualize.ROOT_SCREEN.renderlist, robj3)
glClearColor(1,1,1,1)
renderloop()

