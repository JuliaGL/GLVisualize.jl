using GLVisualize

include(GLVisualize.dir("examples", "ExampleRunner.jl"))
using ExampleRunner
import ExampleRunner: flatten_paths

files = [
    "introduction/rotate_robj.jl",
    "introduction/screens.jl",
    "introduction/simulation.jl",
    "camera/camera.jl",
    "gui/color_chooser.jl",
    "gui/image_processing.jl",
    "gui/buttons.jl",
    "gui/fractal_lines.jl",
    "gui/mandalas.jl",
    "plots/drawing.jl",
    "interactive/graph_editing.jl",
    "interactive/mario_game.jl",
    "plots/3dplots.jl",
    "plots/lines_scatter.jl",
    "plots/hybrid.jl",
    "text/text_particle.jl",
]

map!(x-> GLVisualize.dir("examples", x), files)
files = union(files, flatten_paths(GLVisualize.dir("examples")))
push!(files, GLVisualize.dir("test", "summary.jl"))

# Create an examplerunner, that displays all examples in the example folder, plus
# a runtest specific summary.
config = ExampleRunner.RunnerConfig(
    record = false,
    files = files,
    resolution = (190, 190)
)

ExampleRunner.run(config)
