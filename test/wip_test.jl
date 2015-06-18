using GLVisualize, AbstractGPUArray, GLAbstraction, GeometryTypes, Reactive, ColorTypes, MeshIO, Meshes, FileIO
using GLFW, ModernGL
const screen = GLVisualize.ROOT_SCREEN

t = readall(open("wip_test.jl"))

text = visualize(t)




w = GLVisualize.ROOT_SCREEN
view(background, 							method=:orthographic_pixel)
view(text, 									method=:orthographic_pixel)
view(cursor(text[:positions], selection), 	method=:orthographic_pixel)


renderloop()

