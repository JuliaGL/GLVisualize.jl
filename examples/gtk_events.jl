function add!(window::GtkWindow, ::Type{Area})
    function callback_w(widget::Gtk.GtkGLArea, width::Int32, height::Int32)
        rect = window[Area]
        window[Area] = IRect(minimum(rect), width, height)
        return true
    end
    signal_connect(callback_w, window[Window], "Scroll")
    add_events(window[Window], GConstants.GdkEventMask.SCROLL)
    return
end

function add!(window::GtkWindow, ::Type{Mouse.Scroll})
    function callback(widget::Gtk.GtkGLArea, s::Gtk.GdkEventScroll)
        window[Scroll] = (s.x, s.y)
        return true
    end
    signal_connect(callback, window[NativeWindow], "scroll-event")
    add_events(window[NativeWindow], GConstants.GdkEventMask.SCROLL)
    return
end

function add!(window::GtkWindow, ::Type{Mouse.Position})
    function callback(widget::Gtk.GtkGLArea, s::Gtk.GdkEventMotion)
        window[Mouse.Position] = (s.x, s.y)
        return true
    end
    add_events(window[NativeWindow], GConstants.GdkEventMask.POINTER_MOTION)
    signal_connect(callback, window[NativeWindow], "motion-notify-event")
    return true
end

function to_mouse_button(x)
    if x == 1
        Mouse.left
    elseif x == 2
        Mouse.middle
    elseif x == 3
        Mouse.right
    else
        # TODO turn into error
        warn("Button is $x, while $(Gtk.GdkModifierType.BUTTON1)")
        Mouse.left
    end
end
function add!(window::GtkWindow, ::Type{Mouse.Buttons})
    function callback(widget::Gtk.GtkGLArea, event::Gtk.GdkEventButton)
        button = to_mouse_button(event.button)
        action = event.event_type
        set = window[Mouse.Buttons]
        if action in (GdkEventType.BUTTON_PRESS:GdkEventType.TRIPLE_BUTTON_PRESS)
            push!(set, button)
        elseif action == GdkEventType.BUTTON_RELEASE
            delete!(set, button)
        else
            warn("unknown action: $(action)")
        end
        window[Mouse.Buttons] = set # trigger setfield event!
        return true
    end
    add_events(window[NativeWindow],
        GConstants.GdkEventMask.GDK_BUTTON_PRESS_MASK |
        GConstants.GdkEventMask.GDK_BUTTON_RELEASE_MASK
    )
    signal_connect(callback, window[NativeWindow], "button_press_event")
    signal_connect(callback, window[NativeWindow], "button_release_event")
    return
end
