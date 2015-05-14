using GLVisualize, AbstractGPUArray, GLAbstraction, GeometryTypes, Reactive, ColorTypes
using Meshes, MeshIO, FileIO, WavefrontObj

msh 	= GLNormalMesh(file"cat.obj")
robj 	= visualize(msh)

push!(GLVisualize.ROOT_SCREEN.renderlist, robj)

renderloop()