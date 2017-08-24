
function std_checkbox()
    map(x->map(RGBA{N0f8}, x),
        (loadasset("checked.png"), loadasset("unchecked.png"))
    )
end

function widget(tick::Signal{T}, window;
        checkbox = std_checkbox(), area=(50, 50),
        kw_args...
    ) where T<:Union{Bool, UInt8}
    icon = map(tick) do t
        checkbox[Bool(t) ? 1 : 2]
    end
    robj = visualize(icon; primitive=SimpleRectangle(0,0,area[2],area[2]), kw_args...)
    robj, togl = toggle_button(tick, robj, window)
    robj, togl
end


function choice_visual(x::Union{Function, DataType, Enum}; kw_args...)
    visualize(string(x); kw_args...)
end
function choice_visual(x; kw_args...)
    visualize(x; kw_args...)
end

function widget(enum::Signal{T}, window;
        kw_args...
    ) where T <: Enum
    all_enums = collect(instances(T))
    i0 = findfirst(x-> x==value(enum), all_enums)
    widget(Signal(all_enums), window; kw_args...)
end


function myscale!(robj, target)
    bb = value(boundingbox(robj))
    w1, w2, w3 = widths(bb)
    w = Vec2f0(w1, w2)
    wt1, wt2, wt3 = widths(target)
    wt = Vec2f0(wt1, wt2)
    t = translationmatrix(-minimum(bb))
    t2 = translationmatrix(minimum(target))
    sm = minimum((1f0 ./ w) .* wt)
    s = scalematrix(Vec3f0(sm, sm, 1))
    m = t2*s*t
    set_arg!(robj, :model, m)
    set_arg!(robj, :boundingbox, Signal(m*bb))
end

function widget(choices::Signal{T}, window;
        text_scale = 4mm, start_idx = 1, area = (150, 30), kw_args...
    ) where T <: AbstractVector
    choices_v = value(choices)
    show_area = SimpleRectangle{Float32}(0, 0, area...)
    vizzes = map(enumerate(choices_v)) do i_c
        i, c = i_c
        vis = choice_visual(c;
            relative_scale = text_scale,
            preferred_camera = :fixed_pixel,
            kw_args...
        )
        vs = vis.children[][:visible]
        vs2 = Signal(i == start_idx)

        vis.children[][:visible] = const_lift(vs, vs2) do a, b
            !a ? false : b # only use parent visibility for hiding, not for showing
        end
        push!(vs2, i == start_idx) # doesn't seem to take the correct value otherwise
        myscale!(vis, AABB{Float32}(Vec3f0(5, 5, 0), Vec3f0(area..., 1) - Vec3f0(5,5,0)))
        vis, vs2
    end
    vis = visualize(show_area, color = RGBA{Float32}(0.95, 0.95, 0.95, 0.4)).children[]
    visual = Context(vis, map(first, vizzes)...)
    selected = foldp(start_idx, toggle(visual, window)) do i0, _
        idx = mod1(i0 + 1, length(vizzes))
        for i = 1:length(vizzes)
            push!(vizzes[i][2], i == idx)
        end
        idx
    end
    visual, map(getindex, choices, selected, typ=eltype(choices_v))
end
