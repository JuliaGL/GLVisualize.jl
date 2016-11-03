include("ExampleRunner.jl")
using ExampleRunner
screencast_folder = joinpath(homedir(), "glvisualize_screencast")
!isdir(screencast_folder) && mkdir(screencast_folder)

ExampleRunner.run(
    number_of_frames = 360,
    interactive_time = 5,
    screencast_folder = screencast_folder,
    record=true
)

#Pkg.dir("GLVisualizeDocs", "docs", "media")
include(Pkg.dir("GLVisualize", "src", "examples", "ExampleRunner.jl"))
using ExampleRunner
files = [
   Pkg.dir("GLVisualize", "src", "examples", "parallel", "simulation3d.jl"),
]
# Create an examplerunner, that displays all examples in the example folder, plus
# a runtest specific summary.
config = ExampleRunner.RunnerConfig(
   record=false,
   files = files,
   resolution = (800, 700)
)
ExampleRunner.run(config)
