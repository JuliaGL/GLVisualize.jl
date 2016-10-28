export glscreen



let screen_list = WeakRef[]
    global current_screen, add_screen, get_screens, empty_screens!
    clean() = filter!(x-> x.value != nothing, screen_list)
    current_screen() = (clean(); last(screen_list).value)
    add_screen(screen) = push!(screen_list, WeakRef(screen))
    get_screens() = (clean(); map(x->x.value, screen_list))
    empty_screens!() = empty!(screen_list)
end


function cleanup()
    GLAbstraction.empty_shader_cache!()
    for screen in get_screens()
        destroy!(screen)
    end
    for (k, s) in timer_signal_dict
        close(s.value)
    end
    empty!(timer_signal_dict) # is this even needed?
    empty_screens!()
    reset_texture_atlas!()
end


immutable Millimeter
end
global const mm = Millimeter()
function Base.:(*)(x::Millimeter, y::Number)
    round(Int, y * pixel_per_mm)
end
function Base.:(*)(x::Number, y::Millimeter)
    round(Int, x * pixel_per_mm)
end



function get_dpi(window)
    monitor = GLFW.GetPrimaryMonitor()
    props = GLWindow.MonitorProperties(monitor)
    props.dpi[1]# we do not start fiddling with differently scaled xy dpi's
end



function glscreen(name="GLVisualize";
        resolution = GLWindow.standard_screen_resolution(),
        debugging = false,
        color = RGBA(1,1,1,1),
        stroke = (0f0, color)
    )
    cleanup()
    screen = Screen(name, resolution=resolution, debugging=debugging, color=color)
    add_screen(screen)
    GLWindow.add_complex_signals!(screen) #add the drag events and such
    GLFW.MakeContextCurrent(GLWindow.nativewindow(screen))
    global const pixel_per_mm = get_dpi(screen)/25.4
    screen
end

const timer_signal_dict = Dict{Int, WeakRef}()
"""
Creates a timer signal with `updates_per_second` while `window` is open.
It's reusing timer signals with the same update rate and registering the updates
with GLFW.
"""
function get_timer_signal(updates_per_second, window=current_screen())
    signal = get!(timer_signal_dict, updates_per_second) do
        # because this is a function, it'll only get executed if needed
        WeakRef(fpswhen(window.inputs[:window_open], updates_per_second))
    end.value
    signal
end

function fold_loop(v0, _)
    val, range, index = v0
    val = range[index]
    index += 1
    index>length(range) && (index = 1)
    (val, range, index)
end

function loop(range::Range, rate=60)
    t = get_timer_signal(rate)
    map(first, foldp(fold_loop, (first(range), range, 1), t))
end


function fold_bounce(v0, _)
    val, range, index, direction = v0
    val = range[index]
    index += direction
    if index in (length(range)+1, 0)
        direction = -direction
        index += 2direction
    end
    (val, range, index, direction)
end

function bounce{T}(range::Range{T}, rate=60)
    t = get_timer_signal(rate)
    map(first, foldp(fold_bounce, (first(range), range, 1, 1), t))
end


export bounce, loop
