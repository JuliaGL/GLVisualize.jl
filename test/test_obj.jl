using GLVisualize, AbstractGPUArray, GLAbstraction, GeometryTypes, Reactive, ColorTypes
using Meshes, MeshIO, FileIO, WavefrontObj


robj 	= visualize(file"cat.obj")

push!(GLVisualize.ROOT_SCREEN.renderlist, robj)

renderloop()