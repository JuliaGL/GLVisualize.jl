using GLAbstraction, GLVisualize, Reactive
using GeometryTypes, ColorTypes
using MeshIO, Meshes,FileIO, WavefrontObj

using Base.Test

const TEST_DATA = Any[]
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
	"arbitrary_surface"
]

for test_name in tests
	println("loading: ", test_name, "...")
	include(string("test_", test_name, ".jl"))
	println("...", test_name, " loaded!")
end



w,h = close_to_square(length(TEST_DATA)) 

println("test array size: ", w, " ", h)
grid = reshape(TEST_DATA, (Int(w), Int(h)))
view(visualize(grid))
println("viewing it now")


renderloop()
