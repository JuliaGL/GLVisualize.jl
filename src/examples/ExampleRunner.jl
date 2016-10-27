"""
This is the GLViualize Test suite.
It tests all examples in the example folder and has the options to create
docs from the examples.
"""
module ExampleRunner

using GLAbstraction, GLWindow, GLVisualize
using FileIO, GeometryTypes, Reactive, Images
export RunnerConfig
import GLVisualize: toggle_button, slider, button

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
    rootscreen
    window
    codewindow
    toolbar
    attributes
    current_name
    buttons
end

function RunnerConfig(;
        resolution = (300, 300),
        make_docs = true,
        directory = Pkg.dir("GLVisualize", "src", "examples"),
        exclude_dirs = [
            "gpgpu", "compose", "mouse.jl", "richtext.jl",
            "parallel", "ExampleRunner.jl", "grids.jl"],
        number_of_frames = 360,
        interactive_time = 5.0,
        resampling = 0,
        screencast_folder = pwd(),
        record = true,
        thumbnail = true,
        rootscreen = glscreen(resolution=resolution)
    )
    rootscreen.inputs[:key_pressed] = const_lift(GLAbstraction.singlepressed,
        rootscreen.inputs[:mouse_buttons_pressed],
        GLFW.MOUSE_BUTTON_LEFT
    )
    a, b = y_partition(rootscreen.area, 15)
    toolbar = Screen(rootscreen,
        area=a, color = RGBA(0.95f0, 0.95f0, 0.95f0, 1.0f0)
    )
    toolbar.inputs[:key_pressed]

    ta, tb = x_partition(toolbar.area, 17)
    toolscreen = Screen(toolbar, area=ta)
    toolscreen.inputs[:key_pressed]
    messagescreen = Screen(toolbar, area=tb)
    window = Screen(rootscreen, area=b)
    codewindow = Screen(rootscreen, area=b, hidden=true)
    GLVisualize.add_screen(window)

    paths = [
        "rewind_inactive.png", "rewind_active.png",
        "back_inactive.png", "back_active.png",
        "play.png", "pause.png"
    ]
    imgs = map(paths) do path
        img = map(RGBA{U8}, loadasset(path))
        img, flipdim(img, 1)
    end
    iconsize = size(imgs[1][1],1) / 4

    code_s, code_toggle = widget(
        Signal(["visual", "code",]),
        toolscreen, area=(4*iconsize, iconsize),
        text_scale = Vec2f0(0.5)
    )
    preserve(map(code_s) do id
        window.hidden = id == "code"
        codewindow.hidden = id == "visual"
    end)
    set_arg!(code_toggle, :model, translationmatrix(Vec3f0(1, iconsize*2+2, 0)))
    _view(code_toggle, toolscreen, camera=:fixed_pixel)
    buttons = Dict{Symbol, Any}(
        :rewind => toggle_button(imgs[1][1], imgs[2][1], toolscreen),
        :back => button(imgs[3][1], toolscreen),
        :play => toggle_button(imgs[5][1], imgs[6][1], toolscreen),
        :forward => button(imgs[3][2], toolscreen),
        :fastforward => toggle_button(imgs[1][2], imgs[2][2], toolscreen),
    )

    play_button, play_stop_signal = buttons[:play]
    play_s = map(!, play_stop_signal)
    slider_s, slider_w = slider(
        linspace(0f0, 1f0, 360/3), toolscreen,
        play_signal=play_s,
        slider_length=4*iconsize,
        icon_size=Signal(iconsize)
    )
    buttons[:timesignal] = slider_s

    set_arg!(slider_w.children[1], :stroke_width, 0f0)
    set_arg!(slider_w.children[1], :stroke_color, RGBA(1f0, 1f0, 1f0, 1f0))
    set_arg!(slider_w.children[2], :thickness, 0.7f0)
    set_arg!(slider_w.children[2], :color,RGBA(0.7f0, 0.7f0, 0.7f0, 1f0))

    _view(slider_w, toolscreen, camera=:fixed_pixel)
    last_x = 0f0
    last_y = iconsize+1
    for k in [:rewind, :back, :play, :forward, :fastforward]
        b, s = buttons[k]
        _w,_h,_ = widths(value(boundingbox(b)))
        place = SimpleRectangle{Float32}(last_x+1, last_y+1, _w/4, _h/4)
        layout!(place, b)
        _view(b, toolscreen, camera=:fixed_pixel)
        last_x += (_w/4) + 2
    end

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
        rootscreen,
        window,
        codewindow,
        toolbar,
        Dict(),
        "",
        buttons
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
    render_frame(config.rootscreen)
    pollevents()
    swapbuffers(config.rootscreen)
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
    add_mouse(config.window)
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
    timesignal = config.buttons[:timesignal]
    try
        println("------------------------------------------")
        println("displaying $rel_path")
        name = basename(path)[1:end-3] # remove .jl
        # include the example file in it's own module
        test_module = include_in_module(Symbol(name), path, window, timesignal)
        message = if isdefined(test_module, :description)
            getfield(test_module, :description)
        else
            """
            You can move the camera around
            with the left and right mousebutton
            """
        end
        msg_screen = config.toolbar.children[2]
        empty!(msg_screen)
        w, h = widths(msg_screen)
        _view(visualize(message, model=translationmatrix(Vec3f0(20, (h-20), 0)), relative_scale=Vec2f0(0.3)), msg_screen, camera=:fixed_pixel)
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
        empty!(window)
        empty!(GLVisualize.timer_signal_dict)
        GLWindow.clear_all!(window)
        window.color = RGBA{Float32}(1,1,1,1)
        println("------------------------------------------")
        #empty!(window.cameras)
    end
end


function _test_include(path, config)
    rel_path = relpath(path, config.directory)
    config.current_name = rel_path
    window = config.window
    timesignal = config.buttons[:timesignal]
    name = basename(path)[1:end-3] # remove .jl
    # include the example file in it's own module
    println("------------------------------------------")
    println("displaying $rel_path")
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
    config[:success] = true
    test_module
end

function flatten_paths(path::AbstractString, config, paths = String[])
    if isdir(path)
        if !(basename(path) in config.exclude_dirs)
            for elem in readdir(path)
                flatten_paths(joinpath(path, elem), config, paths)
            end
        end
    elseif isfile(path) && endswith(path, ".jl") && !(basename(path) in config.exclude_dirs)
        push!(paths, path)
    end
    paths
end
function display_msg(test_module, config)
    message = if isdefined(test_module, :description)
        getfield(test_module, :description)
    else
        """
        You can move the camera around
        with the left and right mousebutton
        """
    end
    rel_path = config.current_name
    message = "Now showing $rel_path:\n" * message
    msg_screen = config.toolbar.children[2]
    empty!(msg_screen)
    w, h = widths(msg_screen)
    _view(visualize(
        message, model=translationmatrix(Vec3f0(20, h-20, 0)),
        relative_scale=Vec2f0(0.4), color=RGBA(0.6f0, 0.6f0, 0.6f0, 1f0)
    ), msg_screen, camera=:fixed_pixel)

    path = joinpath(config.directory, rel_path)
    code, colors = GLVisualize.highlighted_text(path)
    # empty code window manually, since we dont want to destroy camera!
    config.codewindow.renderlist = ()
    config.codewindow.renderlist_fxaa = ()
    w, h = widths(config.codewindow)
    _view(visualize(
        code, color=colors, relative_scale=Vec2f0(0.5),
        model=translationmatrix(Vec3f0(20, h-20, 0))
    ), config.codewindow)
end
to_toggle(v0, b) = !v0

function make_tests(path::AbstractString, config)
    paths = flatten_paths(path, config)
    i = 1
    window = config.window
    break_loop = false
    runthrough = 0 # -1, backwards, 0 not, 1 forward
    function increase(x)
        i == length(paths) && (break_loop = true)
        i = max(i+x, 1)
    end
    preserve(map(config.buttons[:back][2], init=0) do clicked
        clicked && (break_loop = true; increase(-1))
    end)
    preserve(map(config.buttons[:forward][2], init=0) do clicked
        clicked && (break_loop = true; increase(1))
    end)

    preserve(map(config.buttons[:fastforward][2], init=0) do toggled
        runthrough = !toggled ? 1 : 0
    end)
    preserve(map(config.buttons[:rewind][2], init=0) do toggled
        runthrough = !toggled ? -1 : 0
    end)

    while i <= length(paths) && isopen(config.rootscreen)
        path = paths[i]
        try
            test_module = _test_include(path, config)
            display_msg(test_module, config)
            firstrun = true; timings = Float64[]
            render_fr(config, timings)
            record_thumbnail(config)
            while !break_loop && isopen(config.rootscreen)
                render_fr(config, timings)
                runthrough != 0 && break # render one time if running through
            end
            config[:timings] = timings
            break_loop = false
            increase(runthrough)
        catch e
            bt = catch_backtrace()
            ex = CapturedException(e, bt)
            showerror(STDERR, ex)
            config[:success] = false
            config[:exception] = ex
        finally
            empty!(window)
            empty!(GLVisualize.timer_signal_dict)
            empty!(config.buttons[:timesignal].actions)

            GLWindow.clear_all!(window)
            window.color = RGBA{Float32}(1,1,1,1)
            #empty!(window.cameras)
        end
        yield()
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
