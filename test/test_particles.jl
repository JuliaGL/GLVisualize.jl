using GLVisualize, AbstractGPUArray, GLAbstraction, MeshIO, GeometryTypes, Reactive

N = 20
function func(x,y)
    R = sqrt(x^2 + y^2)
    sin(R)/R
end

heights = Float32[sin(x/4f0)*sin(y/4f0)/3f0 for x=1:N, y=1:N]
robj 	= surf(Style{:Default}(), heights)
push!(GLVisualize.ROOT_SCREEN.renderlist, robj)

renderloop()