export glscreen

function glscreen(name="GLVisualize";
        resolution = GLWindow.standard_screen_resolution(),
        debugging = false,
        background = RGBA(1,1,1,1)
    )


    screen = Screen(name, resolution=resolution, debugging=debugging, color=background)
    global ROOT_SCREEN  = screen
    global TIMER_SIGNAL = fpswhen(screen.inputs[:window_open], 60.0)

    GLWindow.add_complex_signals!(screen) #add the drag events and such
    preserve(map(screen.inputs[:window_open]) do open
        if !open
            reset_texture_atlas!()
        end
        nothing
    end)
    screen
end


function fold_loop(v0, _)
    val, range, index = v0
    val = range[index]
    index += 1
    index>length(range) && (index = 1)
    (val, range, index)
end

loop(range::Range; t=TIMER_SIGNAL) =
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

bounce{T}(range::Range{T}; t=TIMER_SIGNAL) =
    map(first, foldp(fold_bounce, (first(range), range, 1, 1), t))


export bounce, loop
