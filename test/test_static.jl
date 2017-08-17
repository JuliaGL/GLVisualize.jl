using GLVisualize
include(GLVisualize.dir("examples", "ExampleRunner.jl"))
using ExampleRunner
importall ExampleRunner
using GLAbstraction, GLWindow, Colors
using FileIO, GeometryTypes, Reactive, Images

function image_url(path)
    path, img = splitdir(path)
    path, imgfolder = splitdir(path)
    path, pr = splitdir(path)
    path, package = splitdir(path)
    path, ci = splitdir(path)
    "https://github.com/SimiDCI/GLVisualizeCI.jl/blob/master/reports/$ci/$package/$pr/$imgfolder/$img?raw=true"
end

function create_mosaic(io, folder, width = 150)
    images = filter(x-> endswith(x, ".jpg"), readdir(folder))
    for im in images
        println(io, """<img src="$(image_url(joinpath(folder, im)))"
            alt="$(im)" width=$(width)px"/>
        """)
    end
end

if haskey(ENV, "CI_REPORT_DIR")
    full_folder = ENV["CI_REPORT_DIR"]
    recording = true
else
    recording = false
    full_folder = ""
end

files = [
    "introduction/rotate_robj.jl",
    "introduction/screens.jl",
    "plots/3dplots.jl",
    "plots/lines_scatter.jl",
    "plots/hybrid.jl",
    "camera/camera.jl",
    "gui/color_chooser.jl",
    "gui/image_processing.jl",
    "gui/buttons.jl",
    "gui/fractal_lines.jl",
    "gui/mandalas.jl",
    "plots/drawing.jl",
    "interactive/graph_editing.jl",
    "interactive/mario_game.jl",
    "text/text_particle.jl",
]

map!(x-> GLVisualize.dir("examples", x), files, files)
files = union(files, ExampleRunner.flatten_paths(GLVisualize.dir("examples")))
#push!(files, GLVisualize.dir("test", "summary.jl"))
files = unique(normpath.(files))
# Create an examplerunner, that displays all examples in the example folder, plus
# a runtest specific summary.
resolution = (200, 200)
rootscreen = glscreen(
    resolution = resolution, visible = false,
    focus = false, debugging = true
)
config = ExampleRunner.RunnerConfig(
    record = false,
    record_image = true,
    files = files,
    thumbnail = false,
    screencast_folder = full_folder,
    resolution = resolution,
    rootscreen = rootscreen
)
window = config.window
isdir(full_folder)

if recording
    imgpath = joinpath(full_folder, "images")
    isdir(imgpath) || mkdir(imgpath)
end

for path in config.files
    isopen(config.rootscreen) || break
    try
        println(basename(path))
        test_module = ExampleRunner._test_include(path, config)
        ExampleRunner.display_msg(test_module, config)
        GLWindow.poll_glfw()
        GLWindow.reactive_run_till_now()
        yield()
        render_frame(config.rootscreen)
        swapbuffers(config.rootscreen)
        if recording
            name = basename(path)[1:end-3]
            name = joinpath(imgpath, name * ".jpg")
            GLWindow.screenshot(config.rootscreen, path = name)
        end
    catch e
        #failed[i] = true
        bt = catch_backtrace()
        ex = CapturedException(e, bt)
        showerror(STDERR, ex)
        config[:success] = false
        config[:exception] = ex
    finally
        yield()
        empty!(window)
        window.color = RGBA{Float32}(1,1,1,1)
        window.clear = true
        GLVisualize.empty_screens!()
        empty!(window.cameras)
        GLVisualize.add_screen(window) # make window default again!
        gc()
    end
    yield()
end

failures = filter(config.attributes) do k, dict
    !dict[:success]
end
if recording
    open(joinpath(full_folder, "report.md"), "w") do io
        println(io, "### Test Images:")
        create_mosaic(io, imgpath)
        if !isempty(failures)
            println(io, "### Failures:")
            for (k, dict) in failures
                println(io, "file: $k")
                Base.showerror(io, "$(dict[:exception])")
                println("\n")
            end
        else
            println(io, "No failures! :)")
        end
    end
end

isempty(failures) || error("Tests did not pass!")
