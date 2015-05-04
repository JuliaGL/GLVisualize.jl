using GeometryTypes, MeshIO, Meshes, ColorTypes, GLAbstraction, GLVisualize, Reactive
using Base.Test

const N1 = 7
funcy(x,y,z) = Vec3(sin(x),cos(y),tan(z))
const directions  = Vec3[funcy(x,y,z) for x=1:N1,y=1:N1, z=1:N1]
robj 	= visualize(directions)
msh 	= GLNormalMesh(robj.boundingbox.value)
robj2 	= visualize(msh)
println(robj2.boundingbox.value)

push!(GLVisualize.ROOT_SCREEN.renderlist, robj)
push!(GLVisualize.ROOT_SCREEN.renderlist, robj2)

renderloop()
