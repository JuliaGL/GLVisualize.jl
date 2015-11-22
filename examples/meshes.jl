using GLVisualize, GeometryTypes, GLAbstraction, Colors, FileIO
msh = GLNormalMesh(load("cat.obj"))
w,r = glscreen()

view(visualize(msh))

r()