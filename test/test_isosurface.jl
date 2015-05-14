using GLVisualize, AbstractGPUArray, GLAbstraction, Meshes, MeshIO, GeometryTypes, Reactive, ModernGL
const N2=200
const volume2  = Float32[sin(x/15.0)+sin(y/15.0)+sin(z/15.0) for x=1:N2, y=1:N2, z=1:N2]

max     		= maximum(volume2)
min     		= minimum(volume2)
const volume  	= (volume2 .- min) ./ (max .- min)


msh  		= GLNormalMesh(volume, 0.5f0)
boundingbox = AABB(msh.vertices)
scale = 1f0 / (boundingbox.max - boundingbox.min)

robj = visualize(msh, model=scalematrix(scale)*translationmatrix(-boundingbox.min-Vec3(0.5)))

push!(GLVisualize.ROOT_SCREEN.renderlist, robj)


renderloop()