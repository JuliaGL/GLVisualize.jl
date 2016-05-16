function point_attribs(mh, points_robj, line_robj)
    isoverpoints, isoverlines = mh[1] == points_robj.id, mh[1] == line_robj.id
    points_robj[:glow_color] = isoverpoints ? RGBA{Float32}(0.9,.1,0.2,0.9) : RGBA{Float32}(0.,0.,0.,0.)
    points_robj[:visible] = isoverpoints || isoverlines
end
function point_edit(past, mousediff_index, point_gpu)
    mousediff_past, index_past = past
    mousediff, index = mousediff_index
    if checkbounds(Bool, size(point_gpu), index)
        point_gpu[index] = point_gpu[index] - eltype(point_gpu)(mousediff-mousediff_past)
    end
    mousediff_index
end
function vizzedit{T}(points::Vector{Point{2,T}}, window; color=default(RGBA))
	line 	= visualize(points, :lines, thickness=10f0)
    line_robj = line.children[]
	point_gpu = line_robj[:vertex]
	points 	= visualize((Circle(Point2f0(0), 10f0), point_gpu), glow_width=2f0)
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

function edit_line(
        line, direction_restriction::Vec2f0, clampto, window;
        color=default(RGBA{Float32})
    )
    mouse_hover = mouse2id(window)
	line_robj = visualize(line, :lines, color=color, thickness=10f0).children[]
	point_gpu = line_robj[:vertex]
	points 	  = visualize(
        (Circle(Point2f0(0), 10f0), point_gpu),
        stroke_width=1f0, glow_width=1f0,
        color = RGBA{Float32}(1.0, 1.0, 1.0, 1.0),
        stroke_color = default(RGBA)
    )
    point_robj = points.children[]
	point_robj[:glow_color] = const_lift(is_hovering(point_robj, window)) do h
		h ? RGBA{Float32}(0.9,.1,0.2,0.9) : RGBA{Float32}(0.,0.,0.,0.)
	end
	mousedrag_index = dragged_on(point_robj, MOUSE_LEFT, window)
    drag0, index0   = mousedrag_index.value
	diff_signal = foldp(mouse_drag_diff, (index0, Vec2f0(0), drag0), mousedrag_index)
	diff_signal = droprepeats(const_lift(getindex, diff_signal, 1:2)) #throw away drag, tmp
	preserve(const_lift(gpu_diff_set!, point_gpu, diff_signal, direction_restriction, clampto))
    point_robj[:visible] = preserve(map(mouse_hover) do mh
         mh[1] == point_robj.id || mh[1] == line_robj.id
    end)
	Context(line_robj, points), diff_signal
end

gpu_diff_set!(gpu_object, index_value, direction_restriction, clampto) = gpu_diff_set!(gpu_object, index_value..., direction_restriction, clampto)
function gpu_diff_set!(gpu_object, index, value, direction_restriction, clampto)
	if checkbounds(Bool, size(gpu_object), index)
        T = eltype(gpu_object)
        a = T(value.*direction_restriction)
        np = gpu_object[index] + a
		gpu_object[index] = T(np[1], clamp(np[2], clampto...))
	end
	nothing
end
immutable ClampFunctor{T}
    a::T
    b::T
end
Base.call(c::ClampFunctor, elem) = clamp(elem, c.a, c.b)
Base.clamp(x::FixedVector, a, b) = map(ClampFunctor(a,b) , x)

clampU8(x::RGBA) = RGBA{U8}(ntuple(i->clamp(getfield(x, i), 0.,1.), Val{4})...)
channel_color(channel, value) = RGBA{Float32}(ntuple(i->i==channel ? value : 0.0f0, Val{3})..., 1f0)

function edit_color(tex, buff, index_value, channel, maxval)
    index, value = index_value
    if checkbounds(Bool, size(tex), index)
        color = RGBA{Float32}(buff[index]) - channel_color(channel, value[2]/maxval) # we need buff, since getindex is very slow for textures
        buff[index] = clampU8(color)
        tex[index]  = buff[index]
    end
    nothing
end

function vizzedit(colors::Vector{RGBA{U8}}, window)
	scale_factor = 300
    color_tex    = Texture(colors)
	range        = linspace(1, scale_factor, length(colors))
    dir_restrict = Vec2f0(0,1)
    c = Context()
    for i=1:4
        c_channel = points2f0(Float32[getfield(p, i)*scale_factor for p in colors], range)
        c_i, diff = edit_line(c_channel, dir_restrict, (0, scale_factor), window, color=channel_color(i, 0.8f0))
        #preserve(const_lift(edit_color, color_tex, colors, diff, i, Float32(scale_factor)))
        push!(c, c_i)
    end
    c, color_tex
end
