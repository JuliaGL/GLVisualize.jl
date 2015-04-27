using GLVisualize, AbstractGPUArray, GLAbstraction, MeshIO, GeometryTypes, Reactive


function funcy(x,y,z)
    Vec3(sin(x),cos(y),tan(z))
end
 
N = 7
directions  = Vec3[funcy(0,0,20) for x=1:N,y=1:N, z=1:N]

dirlen 	= 1f0
baselen = 0.05f0
axis 	= [Cube(Vec3(0), Vec3(dirlen, baselen, baselen)), Cube(Vec3(0), Vec3(baselen, dirlen, baselen)), Cube(Vec3(0), Vec3(baselen, baselen, dirlen))]
axis 	= merge(map(GLNormalMesh, axis))

robj 		= visualize(directions)
robj1 		= visualize(axis)

push!(GLVisualize.ROOT_SCREEN.renderlist, robj)
push!(GLVisualize.ROOT_SCREEN.renderlist, robj1)

renderloop()