
drag_x(drag_id) = drag_id[1][1]

printforslider(io::IOBuffer, x::FloatingPoint, numberwidth::Int=5) = print(io, @sprintf("%0.5f", x)[1:numberwidth])
printforslider(io::IOBuffer, x::Integer, numberwidth::Int=5) = print(io, @sprintf("%5d", x)[1:numberwidth])
printforslider(x::Integer, numberwidth::Int=5) = @sprintf("%5d", x)[1:numberwidth]
printforslider(x::FloatingPoint, numberwidth::Int=5) = @sprintf("%0.5f", x)[1:numberwidth]
function printforslider(x::FixedVector, numberwidth=5)
  io = IOBuffer()
  for elem in x
    printforslider(io, elem, numberwidth)
    print(io, " ")
  end
  takebuf_string(io)
end
num2glstring(x, numberwidth) = GLVisualize.process_for_gl(printforslider(x, numberwidth))

FixedSizeArrays.unit{T <: Real}(::Type{T}, _) = one(T)


function add_mouse_drags(t0, mouse_down1, mouseposition1, objectid, id_tolookfor, glyph_width)
    accum, mouse_down0, draggstart, idstart, v0, index0 = t0
    VT = typeof(v0)
    if (!mouse_down0 && mouse_down1) && (objectid[1] == id_tolookfor) #drag starts
        return (accum, mouse_down1, mouseposition1, id_tolookfor, accum, objectid[2]) # reset values
    elseif (mouse_down0 && mouse_down1) && (idstart == id_tolookfor)
        diff = eltype(VT)(Vec2(mouseposition1-draggstart)[1])
        # lets act as if the text glyph array is 2d, with numberwidth as width, and height is the amount of numbers
        zero_indexed        = index0-1 #linear index from glyph array
        number_glyph_group  = div(zero_indexed, glyph_width) # 
        i = number_glyph_group+1#to 1 based index
        return (v0 + (unit(VT, i)*diff), mouse_down1, draggstart, id_tolookfor, v0, index0)
    end
    (accum, mouse_down1, Vec2(0), 0, accum, 0)
end

function vizzedit{T <: Union(FixedVector, Real)}(x::T, inputs, numberwidth=5)
    vizz                = visualize(printforslider(x, numberwidth))
    mbutton_clicked     = inputs[:mousebuttonspressed]

    mousedown           = lift(isnotempty, mbutton_clicked)
    mouse_add_drag_id   = foldl(
        add_mouse_drags, 
        (zero(T), false, Vec2(0), 0, zero(T), 0), 
        mousedown, inputs[:mouseposition], inputs[:mouse_hover], Input(Int(vizz.id)), Input(numberwidth+1) #plus space
    )
    addition_vec = lift(first, mouse_add_drag_id)
    ET      = eltype(T)
    if ET <: FloatingPoint 
        new_num = lift(+, x, lift(/, addition_vec, ET(500)))
    else 
        new_num = lift(+, x, lift(div, addition_vec, ET(10)))
    end 

    new_num_gl = lift(num2glstring, new_num, numberwidth)
    lift(update!, vizz[:glyphs], new_num_gl)
    return new_num, vizz
end
