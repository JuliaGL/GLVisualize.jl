using GLVisualize, AbstractGPUArray, GLAbstraction, MeshIO, GeometryTypes, Reactive, ColorTypes

dirlen 	= 1f0
baselen = 0.02f0
axis 	= [
	GLNormalColorMesh(Cube(Vec3(baselen), Vec3(dirlen, baselen, baselen)), RGBA(1f0,0f0,0f0,1f0)), 
	GLNormalColorMesh(Cube(Vec3(baselen), Vec3(baselen, dirlen, baselen)), RGBA(0f0,1f0,0f0,1f0)), 
	GLNormalColorMesh(Cube(Vec3(baselen), Vec3(baselen, baselen, dirlen)), RGBA(0f0,0f0,1f0,1f0))
]

axis 	= merge(axis)

robj 	= visualize(axis)
push!(GLVisualize.ROOT_SCREEN.renderlist, robj)

renderloop()