using GLAbstraction, GLVisualize, Reactive
using GeometryTypes, ColorTypes
using MeshIO, Meshes,FileIO, WavefrontObj

using Base.Test

const TEST_DATA = Any[]
typealias Point3f Point3{Float32}
const tests = [
	"barplot",
	"surface",
	"isosurface",
	"vectorfield",
	"obj",
	"mesh",
	"particles",
	"dots",
	"volume",
	"sierpinski_mesh",
	"text"
]

for test_name in tests
	println("loading: ", test_name, "...")
	include(string("test_", test_name, ".jl"))
	println("...", test_name, " loaded!")
end


function findclosestsquare(n::Real)
    # a cannot be greater than the square root of n
    # b cannot be smaller than the square root of n
    # we get the maximum allowed value of a
    amax = floor(sqrt(n));
    if 0 == rem(n, amax)
        # special case where n is a square number
        return (amax, n / amax)
    end
    # Get its prime factors of n
    primeFactors  = factor(n);
    # Start with a factor 1 in the list of candidates for a
    candidates = Int[1]
    for (f, _) in primeFactors
        # Add new candidates which are obtained by multiplying
        # existing candidates with the new prime factor f
        # Set union ensures that duplicate candidates are removed
        candidates  = union(candidates, f .* candidates);
        # throw out candidates which are larger than amax
        filter!(x-> x <= amax, candidates)
    end
    # Take the largest factor in the list d
    (Int(candidates[end])::Int, Int(n/candidates[end])::Int)::Tuple{Int, Int}
end

w,h 	 = findclosestsquare(length(TEST_DATA)) 
println(typeof(w))

w = Int(w)
h = Int(h)
println("test array size: ", w, " ", h)
grid = Array(Any, w,h)
for i=1:w, j=1:h
	grid[i,j] = TEST_DATA[sub2ind(size(grid), i,j)]
end
println("viewing it right now")
view(visualize(grid))

renderloop()
