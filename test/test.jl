#=
This is the GLViualize Test suite.
It tests all examples in the example folder and has the options to create
docs from the examples.
=#
module GLTest

using GLAbstraction, GLWindow, GLVisualize
using FileIO, GeometryTypes, Reactive

function record_test(window, timesignal, nframes=1)
    frames = []
    for frame in 1:nframes
        push!(timesignal, frame/nframes)
        yield()
        render_frame(window)
        push!(frames, screenbuffer(window))
    end
    frames
end
function record_test_interactive(window, timesignal)
    frames = []
    add_mouse(window)
    start_time = time()
    for i=1:2 # warm up
        render_frame(window)
    end
    while time()-start_time < 7.0
        push!(timesignal, (start_time-time())/3.0)
        yield()
        render_frame(window)
        yield()
        push!(frames, screenbuffer(window))
    end
    frames
end
function center_cam(camera, renderlist)
    #NOT IMPLEMENTED
end
sboundingbox(robj) = value(boundingbox(robj))

function center_cam(camera::PerspectiveCamera, renderlist)
    bb = mapreduce(sboundingbox, union, renderlist)
    bb_width     = widths(bb)
    lower_corner = minimum(bb)
    middle       = lower_corner + (bb_width/2f0)
    eyeposition  = middle + (norm(bb_width)*Vec3f0(1.5))
    push!(camera.lookat_in, middle)
    push!(camera.eyeposition_in, eyeposition)
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
function save_include(name::Symbol, include_path)
    eval(:(
        module $(name)
            using GLTest

            const runtests   = true
            const window     = GLTest.window
            const timesignal = GLTest.timesignal

            include($include_path)
        end
    ))
end
function test_include(path, window)
    try
        println("trying to render $path")
        name = ucfirst(basename(path)[1:end-3])
        # include the example file in it's own module
        save_include(symbol(name), path)
        # only when something was added to renderlist
        if !isempty(window.renderlist) || !isempty(window.children)
            frames = record_test(window, timesignal)
            println("recorded successfully: $name")
            savepath = Pkg.dir("GLVisualize", "docs", "images", "$name.png")
            save(savepath, first(frames))
            println("saved!")
            push!(working_list, path)
        end
    catch e
        println(e)
    finally
        empty!(window.children)
        empty!(window.renderlist)
        #empty!(window.cameras)
    end
end

function make_tests(path::AbstractString)
    if isdir(path)
        if basename(path) != "compose" && basename(path) != "not_working" && basename(path) != "camera"
            make_tests(map(x->joinpath(path, x), readdir(path)))
        end
    elseif isfile(path) && endswith(path, ".jl") && !in(path, working_list)
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

window = glscreen()
const make_docs  = true
const timesignal = Signal(0.0f0)
srand(777) # set rand seed, to get the same results for tests that use rand

make_tests(Pkg.dir("GLVisualize", "examples"))

open("working.jls", "w") do io
    serialize(io, working_list)
end

end

using GLTest
