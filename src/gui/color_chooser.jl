_clamp(x) = Point2f0(clamp(x[1], 0, 1), clamp(x[2], 0, 1))
function widget(
        color::Signal{T}, window;
        area=(30, 30),
        kw_args...
    ) where T<:RGBA
    @materialize mouse_buttons_pressed, mouseposition = window.inputs
    color_button = visualize(
        (ROUNDED_RECTANGLE, zeros(Point2f0, 1));
        scale = const_lift(x->Vec2f0(x[2]), area),
        offset = Vec2f0(0),
        color = color,
        kw_args...
    )
    color_robj = color_button.children[]
    m2id = GLWindow.mouse2id(window)
    isoverpoint = const_lift(is_same_id, m2id, color_robj)
    key_pressed = map(mouse_buttons_pressed) do mbuttons
        if length(mbuttons) == 1
            b = first(mbuttons)
            return GLFW.MOUSE_BUTTON_LEFT == b || b == GLFW.MOUSE_BUTTON_RIGHT
        end
        false
    end
    # dragg while key_pressed. Drag only starts if isoverpoint is true
    mousedragg = GLAbstraction.dragged(mouseposition, key_pressed, isoverpoint)

    preserve(foldp((value(m2id)..., value(color)), mousedragg) do v0, dragg
        id, index, p0 = v0
        if dragg == Vec2f0(0) # if drag just started. Not the best way, maybe dragged should return a tuple of (draggvalue, started)
            id, index = value(m2id)
            if id == color_robj.id
                p0 = value(color)
            end
        else
            if id == color_robj.id
                mbutton = first(value(mouse_buttons_pressed))
                if mbutton == GLFW.MOUSE_BUTTON_RIGHT # with the right button we control red and green
                    r, g = _clamp(Point2f0(p0.r, p0.g) + Point2f0(dragg/50f0))
                    push!(color, RGBA{eltype(T)}(r, g, p0.b, p0.alpha))
                elseif mbutton == GLFW.MOUSE_BUTTON_LEFT # with the left button we control blue and alpha
                    b, a = _clamp(Point2f0(p0.b, p0.alpha) + Point2f0(dragg/50f0))
                    push!(color, RGBA{eltype(T)}(p0.r, p0.g, b, a))
                end
            end
        end
        return id, index, p0
    end)
    color_button, color
end
