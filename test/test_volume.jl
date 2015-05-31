using GLVisualize, AbstractGPUArray, GLAbstraction, MeshIO, GeometryTypes, Reactive
#=
const N = 128
volume 	= Float32[sin(x/15.0)+sin(y/15.0)+sin(z/15.0) for x=1:N, y=1:N, z=1:N]
max 	= maximum(volume)
min 	= minimum(volume)
volume 	= (volume .- min) ./ (max .- min)
=#

using NPZ
volume 	= map(npzread("mri.npz")["data"]) do x
	Float32(x)/256f0
end
println(size(volume))
obj = visualize(volume, model=translationmatrix(Vec3(-0.5)))

push!(GLVisualize.ROOT_SCREEN.renderlist, obj)

renderloop()