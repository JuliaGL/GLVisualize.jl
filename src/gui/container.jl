function extract_edit_menu(robj::RenderObject, edit_screen, isvisible)
    data = map(robj.uniforms) do kv
        label = replace(string(kv[1]), "_", " ")*":"
        label => kv[2]
    end
    extract_edit_menu(data, edit_screen, isvisible)
end

makesignal2(v) = Signal(v)
makesignal2(s::Signal) = s
makesignal2(v::GPUArray) = v
keytype{K, T}(::Dict{K, T}) = K
keytype{K, T}(::AbstractVector{Pair{K, T}}) = K
keytype{K}(::AbstractVector{Pair{K}}) = K
keytype(x) = Any



function extract_edit_menu{T <: Pair}(
        edit_dict::Union{AbstractVector{T}, Dict}, edit_screen, isvisible;
        mm = 3.71f0, filter_fun = (k, v_v) -> true,
        icon_size = 32, knob_scale = 1.6mm
    )

    screen_w = widths(edit_screen)[1] - round(Int, 10mm)
    pos = 1mm
    widget_text = 4mm
    visses = Pair{UTF8String, Context{GLAbstraction.DeviceUnit}}[]
    K = keytype(edit_dict)
    signal_dict = Dict{K, Any}()
    for (k, v) in edit_dict
        filter_fun(k, v) || continue
        label = UTF8String(string(k))
        s = makesignal2(v)
        if applicable(widget, s, edit_screen)
            vis, sig = widget(s, edit_screen,
                visible = isvisible,
                text_scale = widget_text,
                area = (screen_w, icon_size),
                knob_scale = knob_scale
            )
            push!(visses, label => vis)
            signal_dict[k] = sig
        end
    end
    visualize(visses), signal_dict
end
