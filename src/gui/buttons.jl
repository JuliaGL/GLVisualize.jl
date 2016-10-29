function button(a, window)
    robj = visualize(a).children[]
    const m2id = mouse2id(window)
    is_pressed = droprepeats(map(window.inputs[:key_pressed]) do isclicked
        isclicked && value(m2id).id == robj.id
    end)

    robj[:model] = const_lift(is_pressed, robj[:model], boundingbox(robj)) do ip, old, bb
        ip && return old
        scalematrix(Vec3f0(0.95))*old
    end
    robj, is_pressed
end


function toggle_button(a::Signal, b::Composable, window)
    toggle(b, window, signal=a)
    b, a
end

function toggle_button(a, b, window)
    id = Signal(0)
    ab_bool = toggle(id, window)
    a_b = map(ab_bool) do aORb
        aORb ? a : b
    end
    robj = visualize(a_b)
    push!(id, robj.children[].id)
    robj, ab_bool
end

function toggle(ispressed::Signal{Bool}, window, default=true; signal=Signal(default))
    preserve(map(ispressed) do ispressed
        ispressed && push!(signal, !Bool(value(signal)))
        nothing
    end)
    signal
end

function toggle{T<:Union{Int, Tuple, RenderObject}}(id1::Union{Signal{T}, T}, window, default=true; signal=Signal(default))
    is_clicked = droprepeats(map(window.inputs[:mouse_buttons_pressed]) do mbp
        if GLAbstraction.singlepressed(mbp, GLFW.MOUSE_BUTTON_LEFT)
            id2 = value(mouse2id(window))
            return is_same_id(id2, value(id1))
        end
        false
    end)
    toggle(is_clicked, window, default; signal=signal)
end

function toggle(robj::RenderObject, window, default=true; signal=Signal(default))
    toggle(robj, window, default, signal=signal)
end

function toggle(c::Context, window, default=true; signal=Signal(default))
    toggle(map(x->x.id, tuple(GLAbstraction.extract_renderable(c)...)), window, default, signal=signal)
end


function add_drag(w, range, point_id, slider_length, slideridx_s)
    m2id = mouse2id(w)
    # interaction
    @materialize mouse_buttons_pressed, mouseposition = w.inputs
    isoverpoint = const_lift(is_same_id, m2id, point_id)
    # single left mousekey pressed (while no other mouse key is pressed)
    key_pressed = const_lift(GLAbstraction.singlepressed, mouse_buttons_pressed, GLFW.MOUSE_BUTTON_LEFT)
    # dragg while key_pressed. Drag only starts if isoverpoint is true
    mousedragg = GLAbstraction.dragged(mouseposition, key_pressed, isoverpoint)
    preserve(foldp(value(slideridx_s), mousedragg) do v0, dragg
        if dragg != Vec2f0(0)
            idx_steps = round(Int, (dragg[1]/slider_length)*length(range))
            new_idx = clamp(v0 + idx_steps, 1, length(range))
            push!(slideridx_s, new_idx)
            return v0
        else # dragging started
            return value(slideridx_s)
        end
    end)
    slideridx_s
end
function add_play(slideridx_s, play_signal, range, rate=30.0)
    play_s = fpswhen(play_signal, rate)
    preserve(map(play_s, init=nothing) do t
        push!(slideridx_s, mod1(value(slideridx_s)+1, length(range)))
        nothing
    end)
end

function slider(
        range, window;
        startidx::Int=1,
        play_signal=Signal(false), slider_length=50mm,
        icon_size=Signal(54)
    )
    startpos = 2.1mm
    height = value(icon_size)
    point_id = Signal((0,0))
    slideridx_s = Signal(startidx)
    slider_s = map(slideridx_s) do idx
        range[clamp(idx, 1, length(range))]
    end
    add_drag(window, range, point_id, slider_length, slideridx_s)
    add_play(slideridx_s, play_signal, range)
    bb = map(icon_size) do is
        AABB(Vec3f0(0), Vec3f0(slider_length, is, 1))
    end
    line_pos = map(icon_size) do is
        Point2f0[(startpos, is/2), (slider_length, is/2)]
    end
    line = visualize(
        line_pos, :linesegment,
        boundingbox=bb, thickness=0.9mm
    ).children[]
    i = Signal(0)
    pos = Point2f0[(0, 0)]
    position = map(slideridx_s) do idx
        x = ((idx-1)/length(range-1))*slider_length
        pos[1] = (x, 0)
        pos
    end
    knob_scale = map(is->Vec2f0(is/3), icon_size)
    offset = map(line_pos, icon_size) do lp, is
        p = first(lp)
        Vec2f0(p - (is/6)) # - minus half knob scale
    end
    point_robj = visualize(
        (Circle, position),
        scale_primitive=true,
        offset=offset, scale=knob_scale,
        boundingbox=bb
    ).children[]
    push!(point_id, (point_robj.id, line.id))

    slider_s, Context(point_robj, line)
end

function play_slider(window, icon_size=Signal(54), range=1:360;
    slider_length=200)
    play_button, play_stop_signal = GLVisualize.toggle_button(
        loadasset("checked.png"), loadasset("unchecked.png"), window
    )
    play_s = map(!, play_stop_signal)
    slider_s, slider_w = slider(range, window,
        startidx=1, play_signal=play_s,
        slider_length=slider_length
    )
    slider_s, slider_w, play_button
end
