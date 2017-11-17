function button(a, screen; kw_args...)
    robj = visualize(a; kw_args...).children[]
    m2id = mouse2id(screen)
    is_pressed = droprepeats(map(screen.inputs[:key_pressed]) do isclicked
        isclicked && value(m2id).id == robj.id
    end)

    robj[:model] = const_lift(is_pressed, robj[:model]) do ip, old
        ip && return old
        scalematrix(Vec3f0(0.95))*old
    end
    robj, is_pressed
end


function toggle_button(a::Signal, b::Composable, screen)
    toggle(b, screen, signal=a)
    b, a
end

function toggle_button(a, b, screen; kw_args...)
    id = Signal(0)
    ab_bool = toggle(id, screen)
    a_b = map(ab_bool) do aORb
        aORb ? a : b
    end
    robj = visualize(a_b; kw_args...)
    push!(id, robj.children[].id)
    robj, ab_bool
end

function toggle(ispressed::Signal{Bool}, screen, default=true; signal=Signal(default))
    preserve(map(ispressed) do ispressed
        ispressed && push!(signal, !Bool(value(signal)))
        nothing
    end)
    signal
end

function toggle(id1::Union{Signal{T}, T}, screen, default=true; signal=Signal(default)) where T<:Union{Int, Tuple, RenderObject}
    m2id = mouse2id(screen)
    is_clicked = droprepeats(map(screen.inputs[:mouse_buttons_pressed]) do mbp
        if GLAbstraction.singlepressed(mbp, GLFW.MOUSE_BUTTON_LEFT)
            id2 = value(m2id)
            return is_same_id(id2, value(id1))
        end
        false
    end)
    toggle(is_clicked, screen, default; signal=signal)
end

function toggle(robj::RenderObject, screen, default=true; signal=Signal(default))
    toggle(robj, screen, default, signal=signal)
end

function toggle(c::Context, screen, default=true; signal=Signal(default))
    toggle(map(x->x.id, tuple(GLAbstraction.extract_renderable(c)...)), screen, default, signal=signal)
end


function add_drag(screen, range, point_id, slider_length, slideridx_s)
    m2id = mouse2id(screen)
    # interaction
    @materialize mouse_buttons_pressed, mouseposition = screen.inputs
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
        range, screen;
        startidx::Int = 1,
        play_signal = Signal(false),
        slider_length = 50mm,
        icon_size = Signal(54),
        startpos = 2.1mm,
        knob_scale = map(is-> Vec2f0(is/3), icon_size),
        kw_args...
    )

    point_id = Signal((0,0))
    slideridx_s = Signal(startidx)
    slider_s = map(slideridx_s) do idx
        range[clamp(idx, 1, length(range))]
    end
    add_drag(screen, range, point_id, slider_length, slideridx_s)
    add_play(slideridx_s, play_signal, range)
    bb = map(icon_size) do is
        AABB(Vec3f0(0), Vec3f0(slider_length, is, 1))
    end
    line_pos = map(icon_size) do is
        Point2f0[(startpos, is/2), (slider_length, is/2)]
    end
    line = visualize(
        line_pos, :linesegment;
        boundingbox = bb,
        kw_args...
    ).children[]
    i = Signal(0)
    pos = Point2f0[(0, 0)]
    position = map(slideridx_s) do idx
        x = ((idx-1)/length(range-1)) * slider_length
        pos[1] = (x, 0)
        pos
    end
    offset = const_lift(line_pos, knob_scale) do lp, ks
        p = first(lp)
        Vec2f0(p - (ks / 2)) # - minus half knob scale
    end
    point_robj = visualize(
        (Circle, position),
        scale_primitive = true,
        offset = offset,
        scale = const_lift(Vec2f0, knob_scale),
        boundingbox = bb
    ).children[]

    push!(point_id, (point_robj.id, line.id))

    Context(point_robj, line), slider_s
end


function widget(
        r::Signal{T}, screen::Screen;
        args...
    ) where T <: Range
    slider(value(r), screen; args...)
end
function playbutton(screen; icon_size = 10mm)
    play_button, play_stop_signal = GLVisualize.toggle_button(
        loadasset("play.png"), loadasset("pause.png"), screen,
        primitive = IRect(0, 0, icon_size, icon_size)
    )
end

function play_slider(
        screen, icon_size = Signal(54), range = 1:360;
        slider_length = 200
    )
    play_button, play_stop_signal = playbutton(screen)
    play_s = map(!, play_stop_signal)
    slider_s, slider_w = slider(
        range, screen,
        startidx = 1, play_signal = play_s,
        slider_length = slider_length
    )
    viz = visualize([play_button, slider_s], direction = 1)
    viz, slider_w
end


function labeled_slider(
        range, window;
        text_scale = 5mm,
        text_color = RGBA(0f0, 0f0, 0f0, 1f0),
        kw_args...
    )
    visual, signal = slider(
        range, window;
        kw_args...
    )
    text = visualize(
        map(string, signal), # convert to string
        relative_scale = text_scale,
        color = text_color
    )
    # put in list and visualize so it will get displayed side to side
    # direction = first dimension --> x dimension
    visualize([visual, text],  direction = 1, gap = Vec3f0(3mm, 0, 0)), signal
end
