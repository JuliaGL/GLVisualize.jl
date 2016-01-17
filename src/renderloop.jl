export glscreen

function glscreen(name="GLVisualize")
    screen = createwindow(name)
    global ROOT_SCREEN  = screen
    global TIMER_SIGNAL = fpswhen(screen.inputs[:open], 60.0)

    GLWindow.add_complex_signals!(screen) #add the drag events and such

    screen
end
