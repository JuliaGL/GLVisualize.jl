include(joinpath(dirname(@__FILE__), "..", "src", "examples", "ExampleRunner.jl"))
using ExampleRunner

files = [
    Pkg.dir("GLVisualize", "src", "examples"),
    Pkg.dir("GLVisualize", "test", "summary.jl"),
]
# Create an examplerunner, that displays all examples in the example folder, plus
# a runtest specific summary.
config = ExampleRunner.RunnerConfig(
    record=false,
    files = files,
    resolution = (800, 700)
)

ExampleRunner.run(config)
