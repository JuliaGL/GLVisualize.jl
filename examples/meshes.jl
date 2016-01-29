using GLVisualize, GeometryTypes, GLAbstraction, Colors, FileIO
msh = GLNormalMesh(loadasset("cat.obj"))
w = glscreen()

view(visualize(msh))

renderloop(w)
