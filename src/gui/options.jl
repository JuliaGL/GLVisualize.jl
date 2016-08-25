
function std_checkbox()
    map(x->map(RGBA{U8}, x),
        (loadasset("checked.png"), loadasset("unchecked.png"))
    )
end

function widget{T<:Union{Bool, UInt8}}(tick::Signal{T}, window; checkbox=std_checkbox(), kw_args...)
    icon = map(tick) do t
        checkbox[Bool(t) ? 1 : 2]
    end
    robj = visualize(icon; primitive=SimpleRectangle(0,0,50,50), kw_args...)
    robj, togl = toggle_button(tick, robj, window)
    togl, robj
end


function enum_visual(x::Enum)
    string(x)
end

# function widget{T}(enum::T, window; kw_args...)
#     s = Signal(enum)
#     widget(s, window; kw_args...), s
# end
function widget{T<:Enum}(enum::Signal{T}, window;
        text_scale=Vec2f0(1), kw_args...
    )
    all_enums = instances(T)
    i0 = findfirst(x->x==value(enum), all_enums)
    vis = visualize(const_lift(enum_visual, enum); relative_scale=text_scale, kw_args...)
    preserve(foldp(i0, toggle(vis, window)) do i0, _
        push!(enum, all_enums[i0])
         mod1(i0+1, length(all_enums))
     end)
     enum, vis
end
