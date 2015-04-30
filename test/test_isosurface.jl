using GLVisualize, AbstractGPUArray, GLAbstraction, Meshes, MeshIO, GeometryTypes, Reactive, ModernGL
const N2=200
counter = 15f0
volume2  = Float32[sin(x/counter)+sin(y/counter)+sin(z/counter) for x=1:N2, y=1:N2, z=1:N2]

max     = maximum(volume2)
min     = minimum(volume2)
const volume  = (volume2 .- min) ./ (max .- min)


msh     = GLNormalMesh(volume, 0.5f0)

robj = visualize(msh)

push!(GLVisualize.ROOT_SCREEN.renderlist, robj)


renderloop()