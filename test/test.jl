"""
This is the GLViualize Test suite.
It tests all examples in the example folder and has the options to create
docs from the examples.
"""
module GLTest

using GLAbstraction, GLWindow, GLVisualize
using FileIO, GeometryTypes, Reactive
#using GLVisualize.ComposeBackend

include("videotool.jl")

const number_of_frames = 1
const interactive_time = 0.1
const screencast_folder = joinpath(homedir(), "glvisualize_screencast")
!isdir(screencast_folder) && mkdir(screencast_folder)

function record_test(window, timesignal, nframes=number_of_frames)
    push!(timesignal, 0f0)
    yield()
    render_frame(window) # make sure we start with a valid image
    yield()
    frames = []
    for frame in 1:nframes
        push!(timesignal, frame/nframes)
        render_frame(window)
        push!(frames, screenbuffer(window))
    end
    frames
end
function record_test_static(window)
    yield()
    render_frame(window) # make sure we start with a valid image
    sleep(0.1)
    yield()
    render_frame(window)
    yield()
    render_frame(window)
    return screenbuffer(window)
end
function record_test_interactive(window, timesignal, total_time=interactive_time)
    frames = []
    add_mouse(window)
    push!(timesignal, 0f0)
    for i=1:2 # warm up
        render_frame(window)
        yield()
    end
    start_time = time()

    while time()-start_time < total_time
        push!(timesignal, (start_time-time())/3.0)
        render_frame(window)
        push!(frames, screenbuffer(window))
    end
    frames
end


if isfile("working.jls")
    working_list = open("working.jls") do io
        deserialize(io)
    end
else
    working_list = []
end

"""
 include the example in it's own module
 to avoid variable conflicts.
 this can be done only via eval.
"""
function include_in_module(name::Symbol, include_path)
    eval(:(
        module $(name)
            using GLTest, Reactive

            const runtests   = true
            const window     = GLTest.window
            const timesignal = Signal(0.0f0)

           # const composebackend = GLTest.composebackend

            include($include_path)
        end
    ))
end
function test_include(path, window)
    try
        println("trying to render $path")
        name = basename(path)[1:end-3] # remove .jl
        # include the example file in it's own module
        test_module = include_in_module(symbol(name), path)
        for (camname, cam) in window.cameras
            # don't center non standard cams
            !in(camname, (:perspective, :orthographic_pixel)) && continue
            center!(cam, window.renderlist)
        end
        # only when something was added to renderlist
        if !isempty(window.renderlist) || !isempty(window.children)
            if isdefined(test_module, :record_interactive)
                frames = record_test_interactive(window, test_module.timesignal)
            elseif isdefined(test_module, :static_example)
                frames = record_test_static(window)
            else
                frames = record_test(window, test_module.timesignal)
            end
            println("recorded successfully: $name")
            create_video(frames, name, screencast_folder)
            push!(working_list, path)
        end
    catch e
        println("################################################################")
        bt = catch_backtrace()
        ex = CapturedException(e, bt)
        showerror(STDERR, ex)
        println("\n################################################################")
    finally
        empty!(window.children)
        empty!(window.renderlist)
        #empty!(window.cameras)
    end
end

function make_tests(path::AbstractString)
    if isdir(path)
        if !in(path, working_list) && basename(path) != "compose"
            make_tests(map(x->joinpath(path, x), readdir(path)))
        end
    elseif isfile(path) && endswith(path, ".jl")
        test_include(path, window)
    end
    nothing # ignore other cases
end
function make_tests(directories::Vector)
    for dir in directories
        make_tests(dir)
    end
end

include("mouse.jl")

window = glscreen(resolution=(256, 256))
#composebackend = ComposeBackend.GLVisualizeBackend(window)

const make_docs  = true
srand(777) # set rand seed, to get the same results for tests that use rand
make_tests(Pkg.dir("GLVisualize", "examples"))

open("working.jls", "w") do io
    serialize(io, working_list)
end

end

using GLTest
