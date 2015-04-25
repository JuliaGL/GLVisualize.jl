using GLVisualize, AbstractGPUArray, GLAbstraction, MeshIO, GeometryTypes, Reactive, ColorTypes

robj = visualize(RGBA{Float32}(1,0,0,1), Style{:Default}())
push!(GLVisualize.ROOT_SCREEN.renderlist, robj)

renderloop()