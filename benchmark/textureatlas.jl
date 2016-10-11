include(Pkg.dir("GLVisualize", "test", "ExampleRunner.jl"))
using ExampleRunner
using Base.Test

config = ExampleRunner.RunnerConfig(
    number_of_frames = 1060,
    record=false,
    interactive_time = 5.0,
    resolution = (500, 500),
    directory = Pkg.dir("GLVisualize", "examples", "sprites", "image_texture_atlas.jl")
)
#config.directory = Pkg.dir("GLVisualize", "examples", "interactive", "image_processing.jl")
ExampleRunner.run(config)
x = first(config.attributes)[2][:timings]
using Plots;glvisualize()
plot(x)
