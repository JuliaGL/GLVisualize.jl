using GLVisualize, GLAbstraction, GeometryTypes, Reactive, ColorTypes, ModernGL
w,r = glscreen()
glClearColor(1,1,1,1)
include("utf8_example_text.jl")
text = visualize(utf8_example_text)

view(text)

r()

