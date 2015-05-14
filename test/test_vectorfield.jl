using GLVisualize, AbstractGPUArray, GLAbstraction, GeometryTypes, Reactive, ColorTypes, Meshes, MeshIO

funcy(x,y,z) = Vec3(cos(x/10)+x^2, cos(y/10)+y^2, cos(z/10)+z^2)
 
const N = 7
const directions  = Vec3[funcy(x,y,z) for x=1:N,y=1:N, z=1:N]

robj 	= visualize(directions)
push!(GLVisualize.ROOT_SCREEN.renderlist, robj)

renderloop()