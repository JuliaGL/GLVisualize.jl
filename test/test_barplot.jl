using GLVisualize, AbstractGPUArray, GLAbstraction, Meshes, GeometryTypes, Reactive

const robj = visualize(rand(Float32, 50,50))
push!(GLVisualize.ROOT_SCREEN.renderlist, robj)


renderloop()
