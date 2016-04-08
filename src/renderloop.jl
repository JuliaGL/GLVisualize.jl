export glscreen

function glscreen(name="GLVisualize";
        resolution = GLWindow.standard_screen_resolution(),
        debugging = false,
        background = RGBA(1,1,1,1)
    )


    screen = Screen(name, resolution=resolution, debugging=debugging, color=background)
    global ROOT_SCREEN  = screen

    GLWindow.add_complex_signals!(screen) #add the drag events and such
    preserve(map(screen.inputs[:window_open]) do open
        if !open
            reset_texture_atlas!()
        end
        nothing
    end)
    screen
end

const timer_signal_dict = Dict{Int, WeakRef}()
"""
Creates a timer signal with `updates_per_second` while `window` is open.
It's reusing timer signals with the same update rate and registering the updates
with GLFW.
"""
function get_timer_signal(updates_per_second, window=ROOT_SCREEN)
    signal = get!(timer_signal_dict, updates_per_second) do
        # because this is a function, it'll only get executed if needed
        WeakRef(fpswhen(window.inputs[:window_open], updates_per_second))
    end.value
    # since the renderloop nowadays only updates when something in GLFW happens,
    # we need to register signals that produce events with GLFW.
    preserve(map(x-> GLFW.PostEmptyEvent(), signal))
    signal
end

function fold_loop(v0, _)
    val, range, index = v0
    val = range[index]
    index += 1
    index>length(range) && (index = 1)
    (val, range, index)
end

loop(range::Range; t=get_timer_signal(60)) =
    map(first, foldp(fold_loop, (first(range), range, 1), t))


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

bounce{T}(range::Range{T}; t=get_timer_signal(60)) =
    map(first, foldp(fold_bounce, (first(range), range, 1, 1), t))


export bounce, loop
