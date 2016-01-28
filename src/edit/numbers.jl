
drag_x(drag_id) = drag_id[1][1]

printforslider(io::IOBuffer, x::AbstractFloat, numberwidth::Int=5) = print(io, @sprintf("%0.5f", x)[1:numberwidth])
printforslider(io::IOBuffer, x::Integer, numberwidth::Int=5) = print(io, @sprintf("%5d", x)[1:numberwidth])
printforslider(x::Integer, numberwidth::Int=5) = @sprintf("%5d", x)[1:numberwidth]
printforslider(x::AbstractFloat, numberwidth::Int=5) = @sprintf("%0.5f", x)[1:numberwidth]
function printforslider(x::FixedVector, numberwidth=5)
    io = IOBuffer()
    for elem in x
        printforslider(io, elem, numberwidth)
        print(io, " ")
    end
    takebuf_string(io)
end
function num2glstring(x, numberwidth)
    str   = printforslider(x, numberwidth)
    atlas = get_texture_atlas()
    font  = DEFAULT_FONT_FACE
    Vec4f0[glyph_uv_width!(atlas, c, font) for c=str]
end

FixedSizeArrays.unit{T <: Real}(::Type{T}, _) = one(T)


function add_mouse_drags(t0, mouse_down1, mouseposition1, objectid, id_tolookfor, glyph_width)
    accum, mouse_down0, draggstart, idstart, v0, index0 = t0
    VT = typeof(v0)
    if (!mouse_down0 && mouse_down1) && (objectid[1] == id_tolookfor) #drag starts
        return (accum, mouse_down1, mouseposition1, id_tolookfor, accum, objectid[2]) # reset values
    elseif (mouse_down0 && mouse_down1) && (idstart == id_tolookfor)
        diff = eltype(VT)(Vec2f0(mouseposition1-draggstart)[1])
        # lets act as if the text glyph array is 2d, with numberwidth as width, and height is the amount of numbers
        zero_indexed        = index0-1 #linear index from glyph array
        number_glyph_group  = div(zero_indexed, glyph_width) #
        i = number_glyph_group+1#to 1 based index
        return (v0 + (unit(VT, i)*diff), mouse_down1, draggstart, id_tolookfor, v0, index0)
    end
    (accum, mouse_down1, Vec2f0(0), 0, accum, 0)
end

Base.clamp(x, r::Range) = clamp(x, first(r), last(r))

function slide(startvalue, slide_pos, range::Range)
    val = startvalue + (slide_pos*step(range))
    clamp(val, range)
end

vizzedit{T <: Union{FixedVector, Real}}(x::T, inputs, numberwidth=5) = vizzedit(typemin(T):eps(T):typemax(T), inputs, numberwidth; start_value=x)

function vizzedit(range::Range, window, numberwidth=5; startvalue=middle(range))
    T = typeof(startvalue)
    @materialize mouse_buttons_pressed, mouseposition = window.inputs
    vizz              = visualize(printforslider(startvalue, numberwidth))
    robj              = vizz.children[]
    hovers_slider     = const_lift(is_same_id, mouse2id(window), robj)
    hovers_slider     = filterwhen(hovers_slider, false, hovers_slider)
    left_pressed      = const_lift(GLAbstraction.pressed, mouse_buttons_pressed, GLFW.MOUSE_BUTTON_LEFT)

    addition_vec = droprepeats(GLAbstraction.dragged_diff(mouseposition, left_pressed, hovers_slider))

    ET      = eltype(T)
    new_num = const_lift(slide, startvalue, map(last, addition_vec), range)

    new_num_gl = const_lift(num2glstring, new_num, numberwidth)
    preserve(const_lift(robj[:uv_offset_width], new_num_gl) do uv_off_w, new_num
        update!(uv_off_w, new_num)
    end)
    return new_num, vizz
end
