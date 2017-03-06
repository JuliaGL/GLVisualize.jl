Pkg.checkout("GLFW", "sd/warn")
using GLVisualize
include(GLVisualize.dir("examples", "ExampleRunner.jl"))
using ExampleRunner
import ExampleRunner: flatten_paths

function isheadless()
    get(ENV, "TRAVIS", "") == "true" ||
    get(ENV, "APPVEYOR", "") == "true" ||
    get(ENV, "CI", "") == "true" ||
end

if isheadless()
    include("test_static.jl")
else
    include("test_interactive.jl")
end
