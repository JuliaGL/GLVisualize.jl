export glscreen

function glscreen(name="GLVisualize")
    FreeTypeAbstraction_init()
    atexit(FreeTypeAbstraction_done)


    screen = createwindow(name, debugging=true)
    global ROOT_SCREEN  = screen
    global TIMER_SIGNAL = fpswhen(screen.inputs[:window_open], 60.0)

    GLWindow.add_complex_signals!(screen) #add the drag events and such

    screen
end
function fold_loop(v0, timediff_range)
    _, range = timediff_range
    v0 == last(range) && return first(range)
    v0+step(range)
end

loop(range::Range; t=TIMER_SIGNAL) =
    foldp(fold_loop, first(range), const_lift(tuple, t, range))


function fold_bounce(v0, v1)
    _, range = v1
    val, direction = v0
    val += step(range)*direction
    if val > last(range) || val < first(range)
    direction = -direction
    val += step(range)*direction
    end
    (val, direction)
end

bounce{T}(range::Range{T}; t=TIMER_SIGNAL) =
    const_lift(first, foldp(fold_bounce, (first(range), one(T)), const_lift(tuple, t, range)))


export bounce, loop
