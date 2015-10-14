using GLVisualize, AbstractGPUArray, GLAbstraction, GeometryTypes, Reactive, ColorTypes, Meshes, MeshIO
 

dirlen 	= 1f0
baselen = 0.02f0
cube 	= GLNormalMesh(Cube(Vec3(1), Vec3(1)))
patch(verts, faces) = visualize(GLNormalMesh(verts, faces))
robj1 = patch(cube.vertices, cube.faces)

push!(GLVisualize.ROOT_SCREEN.renderlist, robj1)


renderloop()