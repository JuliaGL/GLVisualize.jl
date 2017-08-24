export glscreen


function _is_alive(x::WeakRef)
    if isa(x.value, Screen)
        isopen(x.value) && return true
    end
    false
end

let screen_list = WeakRef[]
    global current_screen, add_screen, get_screens, empty_screens!
    clean!() = filter!(_is_alive, screen_list)
    function current_screen()
        clean!()
        if isempty(screen_list)
            error("No screen available. Consider creating one with the function glscreen()")
        end
        last(screen_list).value
    end
    add_screen(screen) = push!(screen_list, WeakRef(screen))
    get_screens() = (clean!(); map(x->x.value, screen_list))
    empty_screens!() = empty!(screen_list)
end


function cleanup()
    for screen in get_screens()
        destroy!(screen)
    end
    empty_screens!()
end


struct Millimeter
end
global const mm = Millimeter()

import Base: *
const pixel_per_mm = Ref(3.7)

function (*)(x::Millimeter, y::Number)
    round(Int, y * pixel_per_mm[])
end
function (*)(x::Number, y::Millimeter)
    round(Int, x * pixel_per_mm[])
end



function get_scaled_dpi(window)
    monitor = GLFW.GetPrimaryMonitor()
    props = GLWindow.MonitorProperties(monitor)

    # it seems like small displays with high dpi make mm look quite big.
    # so lets scale it a bit. 518 is a bit arbitrary, but the scale of my
    # screen on which I test everything, hence it will make you see things as I do.
    scaling = props.physicalsize[1] / 518
    min(props.dpi...) * scaling # we do not start fiddling with differently scaled xy dpi's
end



function glscreen(name = "GLVisualize";
        resolution = GLWindow.standard_screen_resolution(),
        debugging = false,
        clear = true,
        color = RGBA(1,1,1,1),
        stroke = (0f0, color),
        hidden = false,
        visible = true,
        focus = true,
        fullscreen = false
    )
    cleanup()
    screen = Screen(
        name,
        resolution = resolution, debugging = debugging,
        clear = clear, color = color, stroke = stroke,
        hidden = hidden, visible = visible, focus = focus,
        fullscreen = fullscreen
    )
    add_screen(screen)
    GLWindow.add_complex_signals!(screen) #add the drag events and such
    GLFW.MakeContextCurrent(GLWindow.nativewindow(screen))
    pixel_per_mm[] = get_scaled_dpi(screen) / 25.4
    screen
end

const timer_signal_dict = Dict{WeakRef, Dict{Int, Signal{Float64}}}()
"""
Creates a timer signal with `updates_per_second` while `window` is open.
It's reusing timer signals with the same update rate and registering the updates
with GLFW.
"""
function get_timer_signal(updates_per_second, window=current_screen())
    dict = get!(timer_signal_dict, WeakRef(window), Dict{Int, Signal{Float64}}())
    get!(dict, updates_per_second) do
        fpswhen(window.inputs[:window_open], updates_per_second)
    end
end

function fold_loop(v0, _)
    val, range, index = v0
    val = range[index]
    index += 1
    index > length(range) && (index = 1)
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

function bounce(range::Range{T}, rate=60) where T
    t = get_timer_signal(rate)
    map(first, foldp(fold_bounce, (first(range), range, 1, 1), t))
end


export bounce, loop
