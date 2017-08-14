function edit_line(
        line, direction_restriction::Vec2f0, clampto, window;
        knob_scale = 9f0,
        knob_color = RGBA{Float32}(0.7, 0.7, 0.7, 1.0),
        kw_args...
    )
    mouse_hover = mouse2id(window)
    inds = reinterpret(Cuint, collect(IterTools.partition(Cuint(0):Cuint(length(line)-1) , 2, 1)))
    line_robj = visualize(
        line, :linesegment;
        indices = inds,
        kw_args...
    ).children[]
    point_gpu = line_robj[:vertex]
    points = visualize(
        (Circle{Float32}(Point2f0(0), knob_scale), point_gpu);
        color = knob_color,
        kw_args...
    )
    point_robj = points.children[]
    gpu_position = point_robj[:position]
    gpu_color = point_robj[:color]
    gpu_scale = point_robj[:scale]

    m2id = mouse2id(window)
    ids = (point_robj.id, line_robj.id)
    isoverpoint = droprepeats(const_lift(is_same_id, m2id, ids))

    @materialize mouse_buttons_pressed, mouseposition = window.inputs

    key_pressed = const_lift(
        GLAbstraction.singlepressed,
        mouse_buttons_pressed, GLFW.MOUSE_BUTTON_LEFT
    )
    mousedragg = GLAbstraction.dragged(
        mouseposition, key_pressed, isoverpoint
    )
    T = Point2f0
    startvalue = (0, 0, Point2f0(0), Point2f0(0))
    sig = foldp(startvalue, mousedragg) do v0, dragg
        id, index, p0, np = v0
        if dragg == Vec2f0(0) # if drag just started. Not the best way, maybe dragged should return a tuple of (draggvalue, started)
            id, index = value(m2id)
            if id==point_robj.id && length(gpu_position) >= index
                p0 = gpu_position[index]
            end
        else
            if id==point_robj.id && length(gpu_position) >= index
                np = p0 + T(dragg).*T(direction_restriction)
                np = T(np[1], clamp(np[2], clampto...))
                gpu_position[index] = np
            end
        end
        return id, index, p0, np
    end

    Context(line_robj, point_robj), map(x->(x[2], x[4]), sig)
end


function widget(
        line::Vector{Point{2,T}}, window;
        direction_restriction = Vec2f0(1),
        clampto = (-Inf, Inf),
        kw_args...
    ) where T
    vis, sig = edit_line(
        line, direction_restriction, clampto, window;
        kw_args...
    )
    pos_gpu = vis.children[2][:position]
    line_s = map(sig) do _
        gpu_data(pos_gpu)
    end
    vis, line_s
end

function mouse_drag_diff(past, drag_index)
    index_past, _, drag_past = past
    drag, index = drag_index
    index, drag-drag_past, drag
end

function dragg_gpu(v0, dragg)
    if dragg == Vec2f0(0) # if drag just started. Not the best way, maybe dragged should return a tuple of (draggvalue, started)
        id, index = value(m2id)
        if id==point_robj.id && length(gpu_position) >= index
            p0 = gpu_position[index]
        else
            p0 = v0[3]
        end
    else
        id, index, p0 = v0
        if id==point_robj.id && length(gpu_position) >= index
            gpu_position[index] = Point2f0(p0) + Point2f0(dragg)
        end
    end
    return id, index, p0
end

struct ClampFunctor{T}
    a::T
    b::T
end

clampU8(x::RGBA{T}) where {T} = RGBA{T}(ntuple(i->clamp(getfield(x, i), 0.,1.), Val{4})...)
channel_color(channel, value) = RGBA{Float32}(ntuple(i->i==channel ? value : 0.0f0, Val{3})..., 1f0)
function c_setindex(color::RGBA{T}, val, channel) where T
    v = clamp.(val, 0, 1)
    RGBA{T}(
        1==channel ? v : comp1(color),
        2==channel ? v : comp2(color),
        3==channel ? v : comp3(color),
        4==channel ? v : alpha(color)
    )
end
function edit_color(tex, buff, index_value, channel, maxval)
    index, value = index_value
    if checkbounds(Bool, tex, index)
        color = c_setindex(buff[index], value[2]/maxval, channel) # we need buff, since getindex is very slow for textures
        buff[index] = color
        tex[index] = color
    end
    nothing
end

function widget(colormap::VecTypes{T}, window;
        area = (300, 30),
        slider_colors = (
            RGBA{Float32}(0.78125,0.1796875,0.41796875),
            RGBA{Float32}(0.41796875,0.78125,0.1796875),
            RGBA{Float32}(0.1796875,0.41796875,0.78125),
            RGBA{Float32}(0.9,0.9,0.9)
        ),
        knob_scale = 9f0,
        kw_args...
    ) where T<:Colorant
    colors = map(GLAbstraction.gl_promote(T), to_cpu_mem(value(colormap)))
    N = length(colors)
    color_tex = GLAbstraction.gl_convert(Texture, colormap)
    @assert colors == to_cpu_mem(color_tex)
    scale = Point2f0(area) .* Point2f0(1, 6)
    dir_restrict = Vec2f0(0,1)
    vis = ntuple(Val{4}) do i
        c_channel = Point2f0[
            Point2f0(x, getfield(c, i)) .* scale for (x, c) in zip(linspace(0,1,N), colors)
        ]
        c_i, diff = edit_line(
            c_channel, dir_restrict,
            (0, scale[2]), window, color=slider_colors[i],
            knob_scale = knob_scale
        )
        preserve(const_lift(edit_color, color_tex, colors, diff, i, scale[2]))
        c_i
    end
    tex = visualize(
        color_tex;
        is_fully_opaque=false,
        primitive=SimpleRectangle{Float32}(0, scale[2]+6, scale[1], 10),
        kw_args...
    )
    Context(tex, vis...), color_tex
end
