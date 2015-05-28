using GLVisualize, GLAbstraction, Meshes, GeometryTypes

const robj = visualize(Float32[(sin(i/10f0) + cos(j/2f0))/4f0 + 1f0 for i=1:10, j=1:10])
push!(GLVisualize.ROOT_SCREEN.renderlist, robj)


renderloop()
