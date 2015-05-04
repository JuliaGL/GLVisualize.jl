using GLVisualize, AbstractGPUArray, GLAbstraction, GeometryTypes, Reactive, ColorTypes, Meshes, MeshIO

funcy(x,y,z) = Vec3(sin(x),cos(y),tan(z))
    
 
N = 7
const directions  = Vec3[funcy(x,y,z) for x=1:N,y=1:N, z=1:N]


robj 	= visualize(directions)
push!(GLVisualize.ROOT_SCREEN.renderlist, robj)

renderloop()