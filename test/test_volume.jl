#Base.depwarn(msg, funcsym)=error(msg, funcsym)

using GLVisualize, AbstractGPUArray, GLAbstraction, MeshIO, GeometryTypes, Reactive

const N = 128

counter = 15.0f0
function test(counter)
	N
	volume 	= Float32[sin(x/counter)+sin(y/counter)+sin(z/counter) for x=1:N, y=1:N, z=1:N]
	counter += 1f0
	max 	= maximum(volume)
	min 	= minimum(volume)
	volume 	= (volume .- min) ./ (max .- min)
	volume
end

vol = lift(test, Input(20f0)) 

obj = visualize(vol)

push!(GLVisualize.ROOT_SCREEN.renderlist, obj)

renderloop()