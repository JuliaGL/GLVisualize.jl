using GLVisualize, Colors, GeometryTypes, Reactive, GLAbstraction, GLFW, GLWindow
import GLVisualize: mm

w = glscreen(); @async GLWindow.waiting_renderloop(w)

function text_with_background(txt;
        background_color = RGBA(1f0, 1f0, 1f0, 1f0), gap = 1mm,
        kw_args...
    )
    robj = visualize(txt; kw_args...).children[]
    rect = map(boundingbox(robj)) do bb
        mini, w = minimum(bb), widths(bb)
        [Point2f0(mini[1] - gap, mini[2] - gap)], Vec2f0(w[1] + 3gap, w[2] + 2gap)
    end
    bg = visualize(
        (RECTANGLE, map(first, rect)),
        scale = map(last, rect),
        offset = Vec2f0(0),
        color = background_color,
        glow_color = RGBA(0f0, 0f0, 0f0, 0.1f0),
        glow_width = 3f0
    )
    Context(bg, robj)
end
slider_val = Signal(1)
slider_str = map(GLVisualize.printforslider, slider_val)
color = Signal(RGBA(1f0, 1f0, 1f0, 1f0))
x = text_with_background(slider_str, relative_scale = 6mm, background_color = color)
GLAbstraction.translate!(x, Vec3f0(4mm, 4mm, 0))
_view(x, w, camera = :fixed_pixel)

ids = (map(x-> x.id, extract_renderable(x))..., )
@materialize mouse_buttons_pressed, buttons_pressed, unicode_input = w.inputs
mouseclick = const_lift(GLAbstraction.singlepressed, mouse_buttons_pressed, GLFW.MOUSE_BUTTON_LEFT)
const enterkey = Set([GLFW.KEY_ENTER])
text_edit = droprepeats(foldp(false, doubleclick(mouseclick, 0.2), buttons_pressed) do v0, clicked, kb
    kb == enterkey && return false
    clicked && is_same_id(value(mouse2id(w)), ids) && return !v0
    v0
end)

preserve(foldp((false, " "), unicode_input, text_edit) do v0, chars, edit
    was_edit, str = v0
    if edit
        if !was_edit
            str = string(value(slider_val))
        end
        for char in chars
            if isnumber(char)
                str *= string(char)
            end
        end
        push!(slider_str, str)
        push!(color, RGBA(0.8f0, 0.8f0, 0.8f0, 0.4f0))
    else
        num = parse(eltype(value(slider_val)), str)
        push!(slider_val, num)
        str = " "
        push!(color, RGBA(1f0, 1f0, 1f0, 1f0))
    end
    edit, str
end)

map(println, unicode_input)
