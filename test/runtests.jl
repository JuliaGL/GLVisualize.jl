include(joinpath(dirname(@__FILE__), "..", "src", "examples", "ExampleRunner.jl"))

using ExampleRunner
using Base.Test
const speed = :slow
files = [
    Pkg.dir("GLVisualize", "src", "examples"),
    Pkg.dir("GLVisualize", "test", "summary.jl"),
]
config = ExampleRunner.RunnerConfig(
    record=false,
    files = files,
    resolution = (800, 700)
)

ExampleRunner.run(config)
