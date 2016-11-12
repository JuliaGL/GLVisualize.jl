include("ExampleRunner.jl")
using ExampleRunner
screencast_folder = joinpath(homedir(), "glvisualize_screencast")
!isdir(screencast_folder) && mkdir(screencast_folder)
config = RunnerConfig(
    number_of_frames = 360,
    interactive_time = 0.1,
    record=false
)

ExampleRunner.run(config)
for (k, v) in config.failed_examples
    println(k)
end
