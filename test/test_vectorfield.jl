using GLVisualize, AbstractGPUArray, GLAbstraction, MeshIO, GeometryTypes, Reactive

function funcy(x,y,z)
    Vec3(sin(x),cos(y),tan(z))
end
 
N = 7
directions  = Vec3[funcy(0,0,20) for x=1:N,y=1:N, z=1:N]

xaxis 	= GLNormalMesh(Cube(Vec3(0), Vec3(1.0, 0.1, 0.1)))
yaxis 	= GLNormalMesh(Cube(Vec3(0), Vec3(0.1, 1.0, 0.1)))
zaxis 	= GLNormalMesh(Cube(Vec3(0), Vec3(0.1, 0.1, 1.0)))


robj 		= visualize(Style{:Default}(), directions)

robj1 		= visualize(xaxis)
robj2 		= visualize(yaxis)
robj3 		= visualize(zaxis)

push!(GLVisualize.ROOT_SCREEN.renderlist, robj)
push!(GLVisualize.ROOT_SCREEN.renderlist, robj1)
push!(GLVisualize.ROOT_SCREEN.renderlist, robj2)
push!(GLVisualize.ROOT_SCREEN.renderlist, robj3)

renderloop()