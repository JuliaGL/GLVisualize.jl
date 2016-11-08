function extract_edit_menu(robj::RenderObject, edit_screen, isvisible)
    data = map(robj.uniforms) do kv
        label = replace(string(kv[1]), "_", " ")*":"
        label => kv[2]
    end
    extract_edit_menu(data, edit_screen, isvisible)
end

makesignal2(s::Signal) = s
makesignal2(v) = Signal(v)
makesignal2(v::GPUArray) = v

function extract_edit_menu(
        edit_dict::Dict, edit_screen, isvisible;
        mm = 3.71f0, filter_fun= (k, v_v) -> true,
        icon_size=32, knob_scale=1.6mm
    )
    lines = Point2f0[]

    screen_w = widths(edit_screen)[1] - round(Int, 10mm)

    labels = String[]
    pos = 1mm
    widget_text = 4mm
    atlas = GLVisualize.get_texture_atlas()
    font = GLVisualize.defaultfont()
    textpositions = Point2f0[]
    for (k,v) in edit_dict
        filter_fun(k, v) || continue
        label = string(k)
        s = makesignal2(v)
        if applicable(widget, s, edit_screen)
            vis, sig = widget(s, edit_screen,
                visible = isvisible,
                text_scale = widget_text,
                area = (screen_w, icon_size),
                knob_scale = knob_scale
            )
            edit_dict[k] = sig
            bb = value(boundingbox(vis))
            height = widths(bb)[2]
            mini = minimum(bb)
            to_origin = -Vec3f0(mini[1], mini[2], 0)
            GLAbstraction.transform!(vis, translationmatrix(Vec3f0(2mm,pos,0)+to_origin))
            _view(vis, edit_screen, camera=:fixed_pixel)
            pos += round(Int, height) + 1mm

            push!(labels, label)
            append!(textpositions,
                GLVisualize.calc_position(label, Point2f0(1mm, pos), widget_text, font, atlas)
            )
            pos += widget_text + 4mm
            push!(lines, Point2f0(0, pos-2mm), Point2f0(screen_w, pos-2mm))

        end
    end
    _view(visualize(
        join(labels), position = textpositions,
        color = RGBA{Float32}(0.8, 0.8, 0.8, 1.0),
        relative_scale = widget_text
    ), edit_screen, camera=:fixed_pixel)

    _view(visualize(
        lines, :linesegment, thickness = 0.25mm,
        color = RGBA{Float32}(0.9, 0.9, 0.9, 1.0)
    ), edit_screen, camera=:fixed_pixel)

    pos
end
