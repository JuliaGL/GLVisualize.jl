Base.depwarn(msg, funcsym)=error(msg, funcsym)

using GLVisualize, AbstractGPUArray, GLAbstraction, MeshIO, GeometryTypes, Reactive

N 		= 128
function func(x,y,z)
    R = sqrt(x^2 + y^2+z^2)
    sin(R)/R
end
counter = 1.0f0
function test(_)
	global counter, N
	volume 	= Float32[sin(x/counter)+sin(y/counter)+sin(z/counter) for x=1:N, y=1:N, z=1:N]
	counter += 1f0
	max 	= maximum(volume)
	min 	= minimum(volume)
	volume 	= (volume .- min) ./ (max .- min)
	volume
end

tex = lift(test, fpswhen(GLVisualize.ROOT_SCREEN.inputs[:open], 2.0)) 

robj = visualize(Style{:Default}(), tex)
push!(GLVisualize.ROOT_SCREEN.renderlist, robj)
renderloop()