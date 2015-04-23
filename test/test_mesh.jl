using GLVisualize, AbstractGPUArray, GLAbstraction, MeshIO, GeometryTypes, Reactive

mesh 	= GLNormalMesh(Cube(Vec3(0), Vec3(2, 1, 1.0)))
robj 	= visualize(Style{:Default}(), mesh)
push!(GLVisualize.ROOT_SCREEN.renderlist, robj)

renderloop()