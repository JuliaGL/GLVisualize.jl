using GLVisualize, AbstractGPUArray, GLAbstraction, GeometryTypes, Reactive, ColorTypes, Meshes, MeshIO

dirlen 	= 1f0
baselen = 0.02f0

robj 	= visualize(GLNormalMesh(Cube(Vec3(0f0), Vec3(1f0))))
push!(GLVisualize.ROOT_SCREEN.renderlist, robj)

renderloop()