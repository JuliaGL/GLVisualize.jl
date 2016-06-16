function point_attribs(mh, points_robj, line_robj)
    isoverpoints, isoverlines = mh[1] == points_robj.id, mh[1] == line_robj.id
    points_robj[:glow_color] = isoverpoints ? RGBA{Float32}(0.9,.1,0.2,0.9) : RGBA{Float32}(0.,0.,0.,0.)
    points_robj[:visible] = isoverpoints || isoverlines
end
function point_edit(past, mousediff_index, point_gpu)
    mousediff_past, index_past = past
    mousediff, index = mousediff_index
    if checkbounds(Bool, point_gpu, index)
        point_gpu[index] = point_gpu[index] - eltype(point_gpu)(mousediff-mousediff_past)
    end
    mousediff_index
end
function edit_line(
        line, direction_restriction::Vec2f0, clampto, window;
        color=default(RGBA{Float32}), kw_args...
    )
    mouse_hover = mouse2id(window)
    line_robj = visualize(
        line, :lines; 
        color=color, thickness=1f0,
        kw_args...
    ).children[]
    point_gpu = line_robj[:vertex]
    points = visualize(
        (Circle(Point2f0(0), 5f0), point_gpu);
        color=RGBA{Float32}(0.7, 0.7, 0.7, 1.0),
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
    key_pressed = const_lift(GLAbstraction.singlepressed, mouse_buttons_pressed, GLFW.MOUSE_BUTTON_LEFT)
    mousedragg = GLAbstraction.dragged(mouseposition, key_pressed, isoverpoint)
    T = Point2f0
    sig = foldp((value(m2id)..., Point2f0(0), Point2f0(0)), mousedragg) do v0, dragg
        np = v0[4]
        if dragg == Vec2f0(0) # if drag just started. Not the best way, maybe dragged should return a tuple of (draggvalue, started)
            id, index = value(m2id)
            if id==point_robj.id && length(gpu_position) >= index
                p0 = gpu_position[index]
            else
                p0 = v0[3]
            end
            np = p0
        else
            id, index, p0, _ = v0
            np = p0
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


function vizzedit{T}(
        points::Vector{Point{2,T}}, window; 
        color=default(RGBA), kw_args...
    )
    line = visualize(points, :lines; thickness=2f0, kw_args...)
    line_robj = line.children[]
    point_gpu = line_robj[:vertex]
    points = visualize(
        (Circle(Point2f0(0), 8f0), point_gpu);
        glow_width=2f0, kw_args...
    )
    points_robj = points.children[]
    preserve(const_lift(point_attribs, window.inputs[:mouse_hover], points_robj, line_robj))
    mousediff_index = dragged_on(points_robj, MOUSE_LEFT, window)
    preserve(foldp(point_edit, mousediff_index.value, mousediff_index, Signal(point_gpu)))
    Context(line, points)
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

immutable ClampFunctor{T}
    a::T
    b::T
end
@compat (c::ClampFunctor)(elem) = clamp(elem, c.a, c.b)
Base.clamp(x::FixedVector, a, b) = map(ClampFunctor(a,b) , x)

clampU8{T}(x::RGBA{T}) = RGBA{T}(ntuple(i->clamp(getfield(x, i), 0.,1.), Val{4})...)
channel_color(channel, value) = RGBA{Float32}(ntuple(i->i==channel ? value : 0.0f0, Val{3})..., 1f0)
function c_setindex{T}(color::RGBA{T}, val, channel)
    v = clamp(val, 0, 1)
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

function vizzedit{T<:Colorant}(colormap::VecTypes{T}, window;
        area = (200, 100),
        slider_colors = (
            RGBA{Float32}(0.41796875,0.78125,0.1796875),
            RGBA{Float32}(0.78125,0.1796875,0.41796875),
            RGBA{Float32}(0.1796875,0.41796875,0.78125),
            RGBA{Float32}(0.9,0.9,0.9)
        ),
        kw_args...
    )
    colors = to_cpu_mem(value(colormap))
    N = length(colors)
    color_tex = GLAbstraction.gl_convert(Texture, colormap)
    scale = Point2f0(area)
    dir_restrict = Vec2f0(0,1)
    vis = ntuple(Val{4}) do i
        c_channel = Point2f0[Point2f0(x, getfield(c, i)) .* scale for (c,x) in zip(colors, linspace(0,1,N))]
        c_i, diff = edit_line(c_channel, dir_restrict, (0, scale[2]), window, color=slider_colors[i])
        preserve(const_lift(edit_color, color_tex, colors, diff, i, scale[2]))
        c_i
    end
    tex = visualize(
        color_tex; 
        is_fully_opaque=false, 
        primitive=SimpleRectangle{Float32}(0, area[2]+6, area[1], 10),
        kw_args...
    )
    color_tex, Context(tex, vis...)
end
