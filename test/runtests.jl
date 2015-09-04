using ModernGL
using FileIO, MeshIO,Meshes, GLAbstraction, GLVisualize, Reactive, GLWindow
using GeometryTypes, ColorTypes, Colors
using Base.Test
w, renderloop = glscreen()



const TEST_DATA   = RenderObject[]
const TEST_DATA2D = RenderObject[]

include(string("all_tests.jl"))

println(length(TEST_DATA))
grid    = reshape(TEST_DATA,   (2,3,3))
grid2D  = reshape(TEST_DATA2D, close_to_square(length(TEST_DATA2D)))

println("reshape done")

xhalf(r)       = Rectangle{Int}(r.x,r.y, div(r.w,2), r.h)
xhalf2(r)      = Rectangle{Int}(div(r.w, 2), r.y, div(r.w, 2), r.h)
const screen3D = Screen(w, area=lift(xhalf, w.area))
const screen2D = Screen(w, area=lift(xhalf2, w.area))
println("screens done")

view(visualize(grid), screen3D)
println("3d done")


view(visualize(grid2D, scale=Vec3f0(200,200,1.0)), screen2D, method=:orthographic_pixel)

println("2d done")

println("viewing it now")
glClearColor(1,1,1,1)

renderloop()