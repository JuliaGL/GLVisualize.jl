using GLVisualize, AbstractGPUArray, GLAbstraction, MeshIO, GeometryTypes, Reactive

function funcy(x,y,z)
    Vec3(sin(x),cos(y),tan(z))
end
 
N = 20
directions  = Vec3[funcy(4x/N*3f0,4y/N,4z/N) for x=1:N,y=1:N, z=1:N]
robj 		= visualize(Style{:Default}(), directions)
push!(GLVisualize.ROOT_SCREEN.renderlist, robj)

renderloop()