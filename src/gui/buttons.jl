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

function toggle(id1::Union{Signal{Int}, Int}, window, default=true)
    droprepeats(foldp(default, window.inputs[:mouse_buttons_pressed]) do v0, mbp
        if GLAbstraction.singlepressed(mbp, GLFW.MOUSE_BUTTON_LEFT)
            id2, index = value(mouse2id(window))
            if value(id1)==id2
                return !v0
            end
        end
        v0
    end)
end

function toggle(robj::RenderObject, window, default=true)
    toggle(Int(robj.id), window, default)
end

function toggle(robj::Context, window, default=true)
    toggle(robj.children[], window, default)
end
