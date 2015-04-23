using GLVisualize, AbstractGPUArray, GLAbstraction, MeshIO, GeometryTypes, Reactive

N = 1024
function func(x,y)
    R = sqrt(x^2 + y^2)
    sin(R)/R
end

positions 	= [Point3{Float32}(sin(x/50f0),cos(x/50f0)/3f0, sin(x)*cos(x)) for x=1:N]
positions 	= reshape(positions, (32, 32))
robj 		= visualize(Style{:Default}(), positions)
push!(GLVisualize.ROOT_SCREEN.renderlist, robj)

renderloop()