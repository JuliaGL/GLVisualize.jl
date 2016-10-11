"""
This is the GLViualize Test suite.
It tests all examples in the example folder and has the options to create
docs from the examples.
"""
module ExampleRunner

using GLAbstraction, GLWindow, GLVisualize
using FileIO, GeometryTypes, Reactive, Images
export RunnerConfig
#using GLVisualize.ComposeBackend
include("mouse.jl")

type RunnerConfig
    resolution
    make_docs
    directory
    exclude_dirs
    number_of_frames
    interactive_time
    resampling
    screencast_folder
    record
    thumbnail
    window
    attributes
    current_name
end

function RunnerConfig(;
        resolution = (300, 300),
        make_docs = true,
        directory = Pkg.dir("GLVisualize", "examples"),
        exclude_dirs = ["gpgpu", "compose"],
        number_of_frames = 360,
        interactive_time = 5.0,
        resampling = 0,
        screencast_folder = pwd(),
        record = true,
        thumbnail = true,
        window = glscreen(resolution=resolution)
    )
    RunnerConfig(
        resolution,
        make_docs,
        directory,
        exclude_dirs,
        number_of_frames,
        interactive_time,
        resampling,
        screencast_folder,
        record,
        thumbnail,
        window,
        Dict(),
        ""
    )
end

function Base.setindex!(x::RunnerConfig, value, sym::Symbol)
    dict = get!(x.attributes, x.current_name, Dict())
    dict[sym] = value
end
function Base.getindex(x::RunnerConfig, sym::Symbol)
    dict = get(x.attributes, x.current_name, Dict())
    dict[sym]
end
function render_fr(config, timings)
    tic()
    render_frame(config.window)
    pollevents()
    swapbuffers(config.window)
    yield() # yield in timings? Seems fair
    push!(timings, toq())
end
function record_thumbnail(config, approx_size=128)
    if config.thumbnail
        thumb = screenbuffer(config.window)
        w,h = size(thumb)
        minlen = min(w,h)
        thumb_sqr = thumb[1:minlen, 1:minlen]
        last_img = thumb_sqr
        while w > approx_size
            last_img = thumb_sqr
            thumb_sqr = restrict(thumb_sqr)
            w = size(thumb_sqr, 1)
        end
        img = if abs(approx_size-w) > abs(approx_size-size(last_img, 1))
            last_img
        else
            thumb_sqr
        end
        config[:thumbnail] = img
    end
end
function record_test(config, timesignal)
    timings = Float64[]
    push!(timesignal, 0f0)
    yield()
    render_fr(config, timings) # make sure we start with a valid image
    yield()
    frames = []
    remaining = (config.number_of_frames-1)
    for frame in 1:remaining
        push!(timesignal, frame/remaining)
        render_fr(config, timings)
        if frame == div(remaining, 2) # create thumb at half time
            record_thumbnail(config)
        end
        config.record && push!(frames, screenbuffer(config.window))

    end
    config[:timings] = timings
    config[:frames] = frames
end
function record_test_static(config)
    timings = Float64[]
    yield()
    render_fr(config, timings) # make sure we start with a valid image
    sleep(0.01)
    yield()
    render_fr(config, timings)
    if config.record
        config[:frames] = screenbuffer(config.window)
    end
    record_thumbnail(config)
    config[:timings] = timings
end
function record_test_interactive(config, timesignal)
    timings = Float64[]
    frames = []
    #add_mouse(config.window)
    push!(timesignal, 0f0)
    for i=1:2 # warm up
        render_fr(config, timings)
        yield()
    end
    start_time = time()
    while time()-start_time < config.interactive_time
        time_diff = time()-start_time
        push!(timesignal, time_diff/config.interactive_time)
        render_fr(config, timings)
        if time_diff >= config.interactive_time/2
            record_thumbnail(config)
        end
        config.record && push!(frames, screenbuffer(config.window))
    end
    config[:timings] = timings
    config[:frames] = frames
end




"""
 include the example in it's own module
 to avoid variable conflicts.
 this can be done only via eval.
"""
function include_in_module(name::Symbol, include_path, window, timesignal)
    eval(:(
        module $(name)
            using Reactive

            const runtests   = true
            const window     = $(window)
            const timesignal = $(timesignal)

           # const composebackend = GLTest.composebackend
            include($include_path)
        end
    ))
end


function test_include(path, config)
    rel_path = relpath(path, config.directory)
    config.current_name = rel_path
    window = config.window
    timesignal = Signal(0.0f0)
    try
        println("------------------------------------------")
        println("displaying $rel_path")
        name = basename(path)[1:end-3] # remove .jl
        # include the example file in it's own module
        test_module = include_in_module(Symbol(name), path, window, timesignal)

        for (camname, cam) in window.cameras
            # don't center non standard cams
            camname != :perspective && continue
            rlist = GLAbstraction.robj_from_camera(window, camname)
            bb = GLAbstraction.renderlist_boundingbox(rlist)
            # make sure we don't center if bb is undefined
            if !isnan(origin(bb))
                center!(cam, bb)
            end
        end
        # only when something was added to renderlist
        if !isempty(renderlist(window)) || !isempty(window.children)
            # record_test_static(config)
            if isdefined(test_module, :record_interactive)
                record_test_interactive(config, timesignal)
            elseif isdefined(test_module, :static_example)
                record_test_static(config)
            else
                record_test(config, timesignal)
            end
            println("displayed successfully")
            if config.record
                create_video(
                    config[:frames], name, config.screencast_folder, config.resampling
                )
                delete!(config.attributes[config.current_name], :frames)
                println("recorded successfully")
            end
        end
        config[:success] = true
    catch e
        bt = catch_backtrace()
        ex = CapturedException(e, bt)
        showerror(STDERR, ex)
        config[:success] = false
        config[:exception] = ex
    finally
        close(timesignal)
        empty!(window)
        empty!(GLVisualize.timer_signal_dict)
        GLWindow.clear_all!(window)
        window.color = RGBA{Float32}(1,1,1,1)
        println("------------------------------------------")
        #empty!(window.cameras)
    end
end

function make_tests(path::AbstractString, config)
    if isdir(path)
        if !(basename(path) in config.exclude_dirs)
            make_tests(map(x->joinpath(path, x), readdir(path)), config)
        end
    elseif isfile(path) && endswith(path, ".jl")
        test_include(path, config)
    end
    nothing # ignore other cases
end
function make_tests(directories::Vector, config)
    for dir in directories
        make_tests(dir, config)
    end
end


function run(;kw_args...)
    config = RunnerConfig(;kw_args...)
    run(config)
end
function run(config::RunnerConfig)
    srand(777) # set rand seed, to get the same results for tests that use rand
    make_tests(config.directory, config)
    config
end


end
