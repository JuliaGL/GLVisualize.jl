include(GLVisualize.dir("test", "ExampleRunner.jl"))
using ExampleRunner
using Base.Test

config = ExampleRunner.RunnerConfig(
    number_of_frames = 1060,
    record=false,
    interactive_time = 5.0,
    resolution = (500, 500),
    directory = GLVisualize.dir("examples", "sprites", "image_texture_atlas.jl")
)
#config.directory = GLVisualize.dir("examples", "interactive", "image_processing.jl")
ExampleRunner.run(config)
x = first(config.attributes)[2][:timings]
using Plots;glvisualize()
plot(x)
