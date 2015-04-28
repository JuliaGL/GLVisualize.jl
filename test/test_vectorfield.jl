using GLVisualize, AbstractGPUArray, GLAbstraction, MeshIO, GeometryTypes, Reactive, ColorTypes

function funcy(x,y,z)
    Vec3(sin(x),cos(y),tan(z))
end
 
N = 7
const directions  = Vec3[Vec3(1,0,0) for x=1:N,y=1:N, z=1:N]
dirlen 	= 1f0
baselen = 0.02f0
axis 	= [
	GLNormalColorMesh(Cube(Vec3(baselen), Vec3(dirlen, baselen, baselen)), RGBA(1f0,0f0,0f0,1f0)), 
	GLNormalColorMesh(Cube(Vec3(baselen), Vec3(baselen, dirlen, baselen)), RGBA(0f0,1f0,0f0,1f0)), 
	GLNormalColorMesh(Cube(Vec3(baselen), Vec3(baselen, baselen, dirlen)), RGBA(0f0,0f0,1f0,1f0))
]
axis 	= merge(axis)
robj 	= visualize(directions)
robj1 	= visualize(axis)

push!(GLVisualize.ROOT_SCREEN.renderlist, robj)
push!(GLVisualize.ROOT_SCREEN.renderlist, robj1)

renderloop()