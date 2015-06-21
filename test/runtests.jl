using GLAbstraction, GLVisualize, Reactive, GLWindow
using GeometryTypes, ColorTypes
using MeshIO, Meshes,FileIO, WavefrontObj

using Base.Test

const TEST_DATA = Any[]
const TEST_DATA2D = Any[]
typealias Point3f Point3{Float32}

const tests = [
    "volume",
	"barplot",
	"surface",
	"isosurface",
	"vectorfield",
	"obj",
	"mesh",
	"particles",
	"dots",
	"sierpinski_mesh",
	"arbitrary_surface",
   # "text",
    "particles2D"
]

for test_name in tests
	println("loading: ", test_name, "...")
	include(string("test_", test_name, ".jl"))
	println("...", test_name, " loaded!")
end


grid    = reshape(TEST_DATA, close_to_square(length(TEST_DATA)) )
grid2D  = reshape(TEST_DATA2D, close_to_square(length(TEST_DATA2D)))

const rs    = GLVisualize.ROOT_SCREEN
xhalf(r)    = Rectangle{Int}(r.x,r.y, r.w/2, r.h)
xhalf2(r)   = Rectangle{Int}(r.w/2, r.y, r.w/2, r.h)
const screen3D = Screen(rs, area=lift(xhalf, rs.area))
const screen2D = Screen(rs, area=lift(xhalf2, rs.area))
view(visualize(grid, screen=screen3D), screen3D)

view(visualize(grid2D, screen=screen2D, scale=Vec3(1000,1000,1.0)), screen2D)

println("viewing it now")


renderloop()
