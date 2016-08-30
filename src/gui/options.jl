
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


function choice_visual(x::Union{Function, DataType, Enum}; kw_args...)
    visualize(string(x); kw_args...)
end
function choice_visual(x; kw_args...)
    visualize(x; kw_args...)
end

function widget{T<:Enum}(enum::Signal{T}, window;
        text_scale=Vec2f0(1), kw_args...
    )
    all_enums = collect(instances(T))
    i0 = findfirst(x->x==value(enum), all_enums)
    choice_widget(all_enums, window; start_idx=i0, text_scale=text_scale, kw_args...)
end


function myscale!(robj, target)
    bb = value(boundingbox(robj))
    w = widths(bb)
    if w[3] == 0.0
        w = Vec3f0(w[1], w[2], 1)
    end
    t = translationmatrix(-minimum(bb))
    t2 = translationmatrix(minimum(target))
    s = scalematrix((1f0./w) .* widths(target))
    m = t2*s*t
    set_arg!(robj, :model, m)
    set_arg!(robj, :boundingbox, Signal(m*bb))
end

function choice_widget(choices::AbstractVector, window;
        text_scale=Vec2f0(1), start_idx=1, area=(150, 30), kw_args...
    )
    show_area = SimpleRectangle(0,0, area...)
    vizzes = map(enumerate(choices)) do i_c
        i, c = i_c
        vis = choice_visual(c;
            relative_scale=text_scale,
            visible=(i==start_idx),
            preferred_camera=:fixed_pixel,
            kw_args...
        )
        myscale!(vis, AABB{Float32}(Vec3f0(2,2,0), Vec3f0(area[2])-Vec3f0(2,2,0)))
        vis
    end
    vis = visualize(show_area, color=RGBA{Float32}(0.95, 0.95, 0.95, 0.4))
    # TODO toggle better
    selected = foldp(mod1(start_idx-1, length(vizzes)), toggle(vis, window)) do i0, _
        idx = mod1(i0+1, length(vizzes))
        for i=1:length(vizzes)
            set_arg!(vizzes[i], :visible, i==idx)
        end
        idx
    end
    map(getindex, Signal(choices), selected, typ=eltype(choices)), Context(vis, vizzes...)
end
