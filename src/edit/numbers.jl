
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
num2glstring(x, numberwidth)  = GLVisualize.process_for_gl(printforslider(x, numberwidth))

FixedSizeArrays.unit{T <: Real}(::Type{T}, _) = one(T)

function vizzedit{T <: Union(FixedVector, Real)}(x::T, inputs, numberwidth=5)
    vizz      = visualize(printforslider(x, numberwidth))
    drag      = inputs[:mousedragdiff_objectid]
    is_num(drag_id) = drag_id[2][1] == vizz.id
    selection_drag  = filter(is_num, (Vec2(0), Vector2(0), Vector2(0)), drag)
    selection       = lift(selection_drag) do s
        s = s[2] # get current tuple of (id, index)
        # lets act as if the text glyph array is 2d, with numberwidth as width, and height is the amount of numbers
        zero_indexed = s[2]-1 #linear index from glyph array
        glyph_width  = numberwidth+1 #plus space
        number_glyph_group = div(zero_indexed, glyph_width) # 
        start_group = ((number_glyph_group)*glyph_width)
        start_group += 1 #to 1 based index
        (number_glyph_group+1, start_group:(start_group+glyph_width-1)) # this is the range of glyphs that represent one number
    end
    slide_addition  = lift(drag_xy, filter(is_num, (Vec2(0), Vector2(0), Vector2(0)), selection_drag))
    mbutton_clicked = inputs[:mousebuttonspressed]
    slide_addition  = lift(
        first, 
        lift(last, 
                foldl(GLAbstraction.mousediff, (false, Vector2(0.0f0), Vector2(0.0f0)), ## (Note 2) 
                    lift(isclicked, mbutton_clicked), slide_addition
                )
            )
        )


    ET = eltype(T)

    if eltype(x) <: FloatingPoint
        new_num = foldl(x, lift(/,slide_addition, ET(500))) do v0, to_add
            v0 - (unit(typeof(v0), selection.value[1])*to_add) # funny way of working around the fact, that we don't have setindex for fixed vectors
            #unit -> Vector(0,0,0,1,0,0) with 1 at index from selection
        end
    else
        addition_vec = foldl(zero(T), slide_addition) do v0, x
            v0 - (unit(T, selection.value[1])*round(ET, x/10.0))
        end
        addition_vec_changed = lift(last, foldl((addition_vec.value, true), addition_vec) do v0, x
            (x, v0[1]!=x)
        end)
        addition_vec = keepwhen(addition_vec_changed, zero(T), addition_vec)
        new_num = lift(+, x, addition_vec)
    end

    new_num_gl = lift(num2glstring, new_num, numberwidth)
    lift(update!, vizz[:glyphs], new_num_gl)
    return new_num, vizz
end
