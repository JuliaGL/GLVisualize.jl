using GLVisualize, Colors, GeometryTypes, Reactive, GLAbstraction, GLFW, GLWindow
import GLVisualize: mm

if !isdefined(:runtests)
    window = glscreen()
end

text_scale = 6mm
function text_with_background(txt;
        background_color = RGBA(1f0, 1f0, 1f0, 1f0), gap = 1mm,
        size = nothing,
        kw_args...
    )
    robj = visualize(txt; kw_args...).children[]
    rect = if size == nothing
        map(boundingbox(robj)) do bb
            mini, w = minimum(bb), widths(bb)
            [Point2f0(mini[1] - gap, mini[2] - gap)], Vec2f0(w[1] + 3gap, w[2] + 2gap)
        end
    else
        Signal(([Point2f0(-gap, -gap)], Vec2f0(size[1] + 3gap, size[2] + 2gap)))
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
slider_str = map(string, slider_val)
color = Signal(RGBA(1f0, 1f0, 1f0, 1f0))
x = text_with_background(
    slider_str, relative_scale = text_scale,
    background_color = color,
    size = (8*text_scale, text_scale)
)
GLAbstraction.translate!(x, Vec3f0(4mm, 4mm, 0))
_view(x, window, camera = :fixed_pixel)

ids = (map(x-> x.id, extract_renderable(x))..., )
@materialize mouse_buttons_pressed, buttons_pressed, unicode_input = window.inputs
mouseclick = const_lift(GLAbstraction.singlepressed, mouse_buttons_pressed, GLFW.MOUSE_BUTTON_LEFT)
const enterkey = Set([GLFW.KEY_ENTER])
text_edit = droprepeats(foldp(false, doubleclick(mouseclick, 0.2), buttons_pressed) do v0, clicked, kb
    kb == enterkey && return false
    clicked && is_same_id(value(mouse2id(window)), ids) && return !v0
    v0
end)
backspace = Set([GLFW.KEY_BACKSPACE])
arrowleft = Set([GLFW.KEY_LEFT])
arrowright = Set([GLFW.KEY_RIGHT])
ctrl_keyes = (backspace, arrowleft, arrowright)


function dont_repeat_value{T}(val, input::Signal{T})
    n = Signal(value(input))
    connect_dont_repeat_value(val, n, input)
    n
end

function connect_dont_repeat_value(val, output, input)
    let prev_value = value(input)
        Reactive.add_action!(input, output) do output, timestep
            nval = value(input)
            println(nval)
            if prev_value != val
                Reactive.send_value!(outputm, nval, timestep)
            end
            prev_value = nval
        end
    end
end

empty_or_ctrl = map(buttons_pressed) do buttons
    if buttons in ctrl_keyes
        buttons
    else
        Set{Int}()
    end
end
# only let controls through
ctrl_buttons = empty_or_ctrl#dont_repeat_value(Set{Int}(), empty_or_ctrl)
println(x.children[2].id)
txt_edit_s = foldp((false, [' '], 1), unicode_input, text_edit, ctrl_buttons) do v0, chars, edit, ctrl
    was_edit, str, cursor = v0
    move(num) = (cursor = clamp(cursor + num, 0, length(str)))
    if edit
        if !was_edit && isempty(ctrl)# reset
            id, idx = value(mouse2id(window))
            empty!(str)
            append!(str, string(value(slider_val)))
            @show id idx
            cursor = if id == x.children[2].id && checkbounds(str, idx)
                idx
            else
                1
            end

        end
        if !isempty(ctrl)
            if ctrl == backspace
                if !isempty(str) && checkbounds(Bool, str, cursor)
                    splice!(str, cursor)
                    move(-1)
                end
            elseif ctrl == arrowleft
                move(-1)
            elseif ctrl == arrowright
                move(1)
            end
        else
            for char in chars
                if isnumber(char)
                    push!(str, char)
                    move(1)
                end
            end
        end
        strstr = join(str)
        if isempty(strstr) # GLVisualize needs to get patched to work with emtpy strings........
            push!(slider_str, " ")
        else
            push!(slider_str, strstr)
        end
        push!(color, RGBA(0.8f0, 0.8f0, 0.8f0, 0.4f0))
    else
        strstr = replace(join(str), ' ', "")
        if !isempty(str)
            num = parse(eltype(value(slider_val)), strstr)
            push!(slider_val, num)
        end
        str = [' ']
        push!(color, RGBA(1f0, 1f0, 1f0, 1f0))
    end
    edit, str, cursor
end

function calc_position(glyphs, idx; scale = text_scale, start_pos = Point2f0(0))
    if checkbounds(Bool, glyphs, idx)
        fonts, atlas = GLVisualize.defaultfont(), GLVisualize.get_texture_atlas()
        GLVisualize.calc_position(glyphs[1:idx], start_pos, scale, fonts, atlas)[end:end]
    elseif idx == 0
        [Point2f0(-1, 1mm)]
    else
        [start_pos]
    end
end

cursor_pos = map(txt_edit_s) do edit_tup
    edit, str, cursor = edit_tup
    calc_position(str, cursor, scale = text_scale, start_pos = Point2f0(text_scale/2 + 1, 1mm))
end
_view(visualize(
    "|",
    position = cursor_pos, visible = text_edit,
    model = transformation(x.children[2]),
    relative_scale = 5mm,
), camera = :fixed_pixel)

if !isdefined(:runtests)
    renderloop(window)
end
