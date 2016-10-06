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
