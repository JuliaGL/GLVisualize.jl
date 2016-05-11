export glscreen



let screen_list = Screen[]
    global current_screen, add_screen
    current_screen() = last(screen_list)
    add_screen(screen) = push!(screen_list, screen)
end


function glscreen(name="GLVisualize";
        resolution = GLWindow.standard_screen_resolution(),
        debugging = false,
        background = RGBA(1,1,1,1)
    )

    screen = Screen(name, resolution=resolution, debugging=debugging, color=background)
    add_screen(screen)

    GLWindow.add_complex_signals!(screen) #add the drag events and such
    add_oit_fxaa_postprocessing!(screen) # add postprocessing

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
function get_timer_signal(updates_per_second, window=current_screen())
    signal = get!(timer_signal_dict, updates_per_second) do
        # because this is a function, it'll only get executed if needed
        WeakRef(fpswhen(window.inputs[:window_open], updates_per_second))
    end.value
    # since the renderloop nowadays only updates when something in GLFW happens,
    # we need to register signals that produce events with GLFW.
    #preserve(map(x-> GLFW.PostEmptyEvent(), signal))
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
