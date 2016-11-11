using GLVisualize

include(GLVisualize.dir("examples", "ExampleRunner.jl"))
using ExampleRunner

files = [
    GLVisualize.dir("examples"),
    GLVisualize.dir("test", "summary.jl"),
]
# Create an examplerunner, that displays all examples in the example folder, plus
# a runtest specific summary.
config = ExampleRunner.RunnerConfig(
    record = false,
    files = files,
    resolution = (190, 190)
)

ExampleRunner.run(config)
