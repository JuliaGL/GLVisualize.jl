using GLVisualize, GLAbstraction, GeometryTypes, Reactive, ColorTypes, Meshes, MeshIO
 
const N = 1000
xy(x,y,i) = Float32(sin(x/i)*sin(y/i))
    
generate(i)             = Float32[xy(x,y,i) for x=1:N, y=1:N]
const distancefield     = lift(generate, bounce(50f0:500f0))

robj1 = visualize(distancefield, :distancefield)
push!(GLVisualize.ROOT_SCREEN.renderlist, robj1)


renderloop()