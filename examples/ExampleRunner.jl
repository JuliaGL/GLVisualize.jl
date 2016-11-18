"""
This is the GLViualize Test suite.
It tests all examples in the example folder and has the options to create
docs from the examples.
"""
module ExampleRunner

# add one worker process for parallel examples

using GLAbstraction, GLWindow, GLVisualize
using FileIO, GeometryTypes, Reactive, Images
export RunnerConfig
import GLVisualize: toggle_button, slider, button, mm

import Compat: String, UTF8String

include("mouse.jl")


const installed_pkgs = Pkg.installed()

const hasplots = get(installed_pkgs, "Plots", v"0") > v"0.9.3"
if !hasplots
    warn("
        Plots.jl is not installed, excluding a lot of interesting examples from the test
        and a nice summary.
        Please consider doing: `Pkg.add(\"Plots\"); Pkg.checkout(\"Plots\", \"dev\")`
    ")
end

include("texthighlight.jl")

function flatten_paths(files::Vector, paths = String[])
    for file in files
        flatten_paths(file, paths)
    end
    paths
end
function flatten_paths(path::String, paths = String[])
    if isdir(path)
            flatten_paths(map(x-> joinpath(path, x), readdir(path)), paths)
    elseif isfile(path) && endswith(path, ".jl")
        push!(paths, path)
    end
    paths
end

type RunnerConfig
    resolution
    make_docs
    files
    exclude_dirs
    number_of_frames
    interactive_time
    resampling
    screencast_folder
    record
    thumbnail
    rootscreen
    window
    code_screen
    toolbar
    attributes
    current_file
    buttons
end
const preserved_signals = Set([])

add_all_signals!(signal::Void) = nothing
function add_all_signals!(signal)
    push!(preserved_signals, signal)
    for a in signal.actions
        add_all_signals!(a.recipient.value)
    end
end
should_preserve(signal::Void, preserved_signals) = false

function should_preserve(signal, preserved_signals)
    if signal in preserved_signals
        return true
    else
        for elem in signal.actions
            if should_preserve(elem.recipient.value, preserved_signals)
                return true
            end
        end
    end
    false
end
clean_up_signals!(signal::Void) = nothing
function clean_up_signals!(signal)
    if !should_preserve(signal, preserved_signals)
        close(signal, false)
    else
        for elem in signal.actions
            clean_up_signals!(elem.recipient.value)
        end
    end
    return
end

const text_signals = Dict(
    :title => Signal(UTF8String, "Nothing to show"),
    :message => Signal(UTF8String, "\n"),
    :codepath => Signal(UTF8String, ""),
)


function create_screens(rootscreen)
    # partition screen into 4 areas at 15% and 17%
    iconsize = 10mm
    tool_area, view_area = y_partition_abs(rootscreen.area, 3iconsize) # three rows
    control_area, message_area = x_partition_abs(tool_area, 4.5iconsize) # 4.5 columns

    toolbar = Screen(rootscreen,
        area = tool_area, color = RGBA(0.95f0, 0.95f0, 0.95f0, 1.0f0)
    )
    messagescreen = Screen(toolbar, area = message_area)
    control_screen = Screen(toolbar, area = control_area)

    # load the icons
    paths = [
        "rewind_inactive.png", "rewind_active.png",
        "back_inactive.png", "back_active.png",
        "play.png", "pause.png"
    ]
    imgs = map(paths) do path
        img = map(RGBA{U8}, loadasset(path))
        img, flipdim(img, 1)
    end

    code_toggle, code_s = widget(
        Signal(["code", "visual"]),
        relative_scale = 9mm,
        control_screen, area = (4*iconsize, iconsize),
    )

    # set up code and view screen
    code_hide = map(id-> id == "code", code_s)
    view_hide = map(id-> id == "visual", code_s)
    view_screen = Screen(
        rootscreen, area = view_area, hidden = view_hide
    )
    # `copy` all signals to make cleaning up easier
    for (k, v) in view_screen.inputs
        view_screen.inputs[k] = map(identity, v)
    end
    code_screen = Screen(rootscreen, area = view_area, hidden = code_hide)
    GLVisualize.add_screen(view_screen)

    # setup message and code display
    text_color = map(text_signals[:title], text_signals[:message]) do title, message
        colors = [
            fill(RGBA(0.3f0, 0.3f0, 0.3f0, 1f0), length(title));
            fill(RGBA(0.6f0, 0.6f0, 0.6f0, 1f0), length(message));
        ]
        title*message, colors
    end
    _view(visualize(
        map(first, text_color),
        color = map(last, text_color),
        relative_scale = 4mm
    ), messagescreen, camera = :orthographic_pixel)

    text_color = map(text_signals[:codepath]) do codepath
        if isfile(codepath)
            code, colors = highlight_text(codepath)
        else
            txt = "error: file $codepath not found"
            colors = fill(RGBA(0f0,0f0,0f0,1f0), length(txt))
            txt, colors
        end
    end
    _view(visualize(
        map(first, text_color), color = map(last, text_color),
        relative_scale = 4mm
    ), code_screen, camera = :orthographic_pixel)

    set_arg!(
        code_toggle, :model,
        translationmatrix(Vec3f0(1, iconsize * 2 + 2, 0))
    )
    _view(code_toggle, control_screen, camera=:fixed_pixel)

    # create buttons
    buttons = Dict{Symbol, Any}(
        :rewind => toggle_button(imgs[1][1], imgs[2][1], control_screen),
        :back => button(imgs[3][1], control_screen),
        :play => toggle_button(imgs[5][1], imgs[6][1], control_screen),
        :forward => button(imgs[3][2], control_screen),
        :fastforward => toggle_button(imgs[1][2], imgs[2][2], control_screen),
    )

    play_button, play_stop_signal = buttons[:play]
    play_s = map(!, play_stop_signal)

    slider_w, slider_s = slider(
        linspace(0f0, 1f0, 120), control_screen,
        play_signal = play_s,
        slider_length = 4*iconsize,
        icon_size = Signal(iconsize)
    )
    buttons[:timesignal] = slider_s

    set_arg!(slider_w.children[1], :stroke_width, 0f0)
    set_arg!(slider_w.children[1], :stroke_color, RGBA(1f0, 1f0, 1f0, 1f0))
    set_arg!(slider_w.children[2], :thickness, 0.8f0)
    set_arg!(slider_w.children[2], :color, RGBA(0.7f0, 0.7f0, 0.7f0, 1f0))

    _view(slider_w, control_screen, camera=:fixed_pixel)
    last_x = 0f0
    last_y = iconsize+1
    for k in [:rewind, :back, :play, :forward, :fastforward]
        b, s = buttons[k]
        push!(preserved_signals, s)

        _w, _h, _ = widths(value(boundingbox(b)))
        ratio = _w / _h
        x_width = ratio * iconsize # we have half widthed icons
        place = SimpleRectangle{Float32}(
            last_x+1, last_y+1,
            x_width, iconsize
        )
        layout!(place, b)
        _view(b, control_screen, camera=:fixed_pixel)
        last_x += x_width + 0.5mm
    end

    toolbar, code_screen, view_screen, buttons

end

function RunnerConfig(;
        resolution = (300, 300),
        make_docs = true,
        files = String[],
        exclude_dirs = [
            "parallel", "compose", "mouse.jl", "richtext.jl",
            "ExampleRunner.jl", "grids.jl",
            "texthighlight.jl"
        ],
        number_of_frames = 360,
        interactive_time = 5.0,
        resampling = 0,
        screencast_folder = pwd(),
        record = true,
        thumbnail = true,
        rootscreen = glscreen(resolution=resolution)
    )
    w, h = resolution
    resize!(rootscreen, w*mm, h*mm)
    yield() # let screen area signal arrive
    if !hasplots
        push!(exclude_dirs, "plots")
        push!(exclude_dirs, "summary.jl")
    end
    if !haskey(installed_pkgs, "BilliardModels")
        push!(exclude_dirs, "billiard.jl")
    end

    control_screen, code_screen, view_screen, buttons = create_screens(rootscreen)

    if isempty(files)
        push!(files, flatten_paths(GLVisualize.dir("examples"))) # make sure we have something to show
    end
    files = filter(files) do file
        !(basename(file) in exclude_dirs) &&
        !(basename(dirname(file)) in exclude_dirs)
    end

    RunnerConfig(
        resolution,
        make_docs,
        files,
        exclude_dirs,
        number_of_frames,
        interactive_time,
        resampling,
        screencast_folder,
        record,
        thumbnail,
        rootscreen,
        view_screen,
        code_screen,
        control_screen,
        Dict(),
        "",
        buttons
    )
end

function Base.setindex!(x::RunnerConfig, value, sym::Symbol)
    dict = get!(x.attributes, x.current_file, Dict())
    dict[sym] = value
end
function Base.getindex(x::RunnerConfig, sym::Symbol)
    dict = get(x.attributes, x.current_file, Dict())
    dict[sym]
end


function record_thumbnail(config, approx_size=128)
    if config.thumbnail && isopen(config.window)
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


"""
 include the example in it's own module
 to avoid variable conflicts.
 this can be done only via eval.
"""
function include_in_module(name::Symbol, config, include_path, window, timesignal)
    eval(:(
        module $(name)
            using Reactive

            const runtests   = true
            const config     = $(config)
            const window     = $(window)
            const timesignal = $(timesignal)

           # const composebackend = GLTest.composebackend
            include($include_path)
        end
    ))
end



function _test_include(path, config)
    config.current_file = path
    timesignal = config.buttons[:timesignal]
    name = basename(path)[1:end-3] # remove .jl
    # include the example file in it's own module
    window = config.window
    test_module = include_in_module(Symbol(name), config, path, window, timesignal)
    for (camname, cam) in window.cameras
        # don't center non standard cams
        camname in (:orthographic_pixel, :perspective) || continue
        rlist = GLAbstraction.robj_from_camera(window, camname)
        bb = GLAbstraction.renderlist_boundingbox(rlist)
        # make sure we don't center if bb is undefined
        if !isnan(origin(bb))
            center!(cam, bb)
        end
    end
    config[:success] = true
    test_module
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
    # make sure this is still needed
    if isopen(config.toolbar) && !isempty(config.toolbar.children)
        name = basename(config.current_file)
        title = "Now showing $name:\n"
        println(title)

        push!(text_signals[:title], title)
        push!(text_signals[:message], message)
        cam = config.toolbar.children[1].cameras[:orthographic_pixel]
        pad = 20
        w, h = widths(config.toolbar.children[1])
        center!(cam, AABB(Vec3f0(-pad, -h+2pad, 0), Vec3f0(w-pad, h-2pad, 0)))

        push!(text_signals[:codepath], config.current_file)
        cam = config.code_screen.cameras[:orthographic_pixel]
        w, h = widths(config.code_screen)
        center!(cam, AABB(Vec3f0(-pad, -h+3pad, 0), Vec3f0(w-pad, h-3pad, 0)))
    end
    return
end
to_toggle(v0, b) = !v0


import GLWindow: poll_reactive, poll_glfw, sleep_pessimistic

function make_tests(config)
    i = 1; frames = 0; window = config.window; break_loop = false
    runthrough = 0 # -1, backwards, 0 no running, 1 forward

    function increase(x = runthrough)
        x = x == 0 ? 1 : x
        i = max(i+x, 1)
        if i <= length(failed) && failed[i]
            increase(x)
        end
        i
    end

    preserve(map(config.buttons[:back][2], init=0) do clicked
        clicked && (break_loop = true; increase(-1))
    end)
    preserve(map(config.buttons[:forward][2], init=0) do clicked
        clicked && (break_loop = true; increase(1))
    end)

    preserve(map(config.buttons[:fastforward][2], init = 0) do toggled
        # reset frames, so we loop a few times longer before loading next example
        # this will keep the buttons responsive
        frames = 0
        runthrough = !toggled ? 1 : 0
    end)
    preserve(map(config.buttons[:rewind][2], init = 0) do toggled
        frames = 0
        runthrough = !toggled ? -1 : 0
    end)
    failed = fill(false, length(config.files))
    Reactive.stop() # stop Reactive! We be pollin' ourselves!
    while i <= length(config.files) && isopen(config.rootscreen)
        path = config.files[i]
        try
            test_module = _test_include(path, config)

            display_msg(test_module, config)
            timings = Float64[]
            frames = 0
            while !break_loop && isopen(config.rootscreen)
                tic()
                poll_glfw()
                if Base.n_avail(Reactive._messages) > 0
                    poll_reactive()
                    poll_reactive() # two times for secondary signals
                    render_frame(config.rootscreen)
                    swapbuffers(config.rootscreen)
                    yield() # yield in timings? Seems fair
                end
                frames += 1
                t = toq()
                if length(timings) < 1000 && frames > 2
                    push!(timings, t)
                end
                GLWindow.sleep_pessimistic((1/60) - t)
                (runthrough != 0 && frames > 20) && break
            end
            record_thumbnail(config) # record thumbnail in the end
            config[:timings] = timings
            break_loop = false
            runthrough != 0 && increase()
            for n in names(test_module, true)
                x = getfield(test_module, n)
                if n != :timesignal && isa(x, Signal) && !(x in values(window.inputs))
                    close(x, false)
                end
            end
        catch e
            #failed[i] = true
            increase() # skip example
            bt = catch_backtrace()
            ex = CapturedException(e, bt)
            showerror(STDERR, ex)
            config[:success] = false
            config[:exception] = ex
        finally
            empty!(window)
            empty!(config.buttons[:timesignal].actions)
            window.color = RGBA{Float32}(1,1,1,1)
            window.clear = true
            GLVisualize.empty_screens!()
            GLVisualize.add_screen(window) # make window default again!
            for (k, s) in window.inputs
                empty!(s.actions)
            end
            empty!(window.cameras)
            gc()
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
    make_tests(config)
    config
end


end
