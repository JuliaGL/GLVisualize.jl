using GLAbstraction, GLVisualize, Reactive, GLWindow
using GeometryTypes, ColorTypes
using MeshIO, Meshes,FileIO, WavefrontObj

using Base.Test

const TEST_DATA = Any[]
const TEST_DATA2D = Any[]
typealias Point3f Point3{Float32}


include(string("all_tests.jl"))


grid    = reshape(TEST_DATA, 	close_to_square(length(TEST_DATA)) )
grid2D  = reshape(TEST_DATA2D, 	close_to_square(length(TEST_DATA2D)))

println("reshape done")

const rs    = GLVisualize.ROOT_SCREEN
xhalf(r)    = Rectangle{Int}(r.x,r.y, round(Int, r.w/2), r.h)
xhalf2(r)   = Rectangle{Int}(round(Int, r.w/2), r.y, round(Int, r.w/2), r.h)
const screen3D = Screen(rs, area=lift(xhalf, rs.area))
const screen2D = Screen(rs, area=lift(xhalf2, rs.area))
println("screens done")

view(visualize(grid), screen3D)
println("3d done")


view(visualize(grid2D, scale=Vec3(1000,1000,1.0)), screen2D)
println("2d done")


println("viewing it now")
renderloop()
