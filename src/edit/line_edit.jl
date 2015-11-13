float_diff(a,b) = Vec2f2(a-b)
function vizzedit{T}(points::Vector{Point{2,T}}, window; color=default(RGBA))
	line 	= visualize(Input(points), :lines)
	point_gpu = line[:vertex]
	points 	= visualize(Texture(point_gpu), shape=Cint(CIRCLE), style=Cint(GLOWING) | Cint(FILLED) | Cint(OUTLINED))
	hovering_lines  = is_hovering(line, window)
	hovering_points = is_hovering(points, window)
	points[:glow_color] = const_lift(hovering_points) do h
		h ? RGBA{Float32}(0.9,.1,0.2,0.9) : RGBA{Float32}(0.,0.,0.,0.)
	end
	mousediff_index = dragged_on(points, MOUSE_LEFT, window)
	foldl(mousediff_index.value, mousediff_index) do past, mousediff_index
		mousediff_past, index_past = past
		mousediff, index = mousediff_index
		if checkbounds(Bool, size(point_gpu), index)
			point_gpu[index] = point_gpu[index] - eltype(point_gpu)(mousediff-mousediff_past)
		end
		mousediff_index
	end
	points[:visible] = lift(OR, hovering_lines, hovering_points)
	Context(line, points)
end

function mouse_drag_diff(past, drag_index)
	index_past, _, drag_past = past
	drag, index = drag_index
	index, drag-drag_past, drag
end

function edit_line(
        line, direction_restriction::Vec2f0, clampto, window; 
        color=default(RGBA{Float32}, Style{:default}())
    )
	line_robj = visualize(Input(line), :lines, color=color, thickness = 4f0)
	point_gpu = line_robj[:vertex]
	points 	  = visualize(
        Texture(point_gpu), 
        shape=Cint(CIRCLE), 
        style=Cint(GLOWING) | Cint(FILLED) | Cint(OUTLINED),
        transparent_picking = true,
        color = RGBA{Float32}(1.0, 1.0, 1.0, 1.0),
        stroke_color = RGBA{Float32}(0.7,0.7,0.7, 1.0)
    )
	hovering_lines  = is_hovering(line_robj, window)
	hovering_points = is_hovering(points, window)
	points[:glow_color] = const_lift(hovering_points) do h
		h ? RGBA{Float32}(0.9,.1,0.2,0.9) : RGBA{Float32}(0.,0.,0.,0.)
	end
	mousedrag_index = dragged_on(points, MOUSE_LEFT, window)
    drag0, index0   = mousedrag_index.value
	diff_signal = foldl(mouse_drag_diff, (index0, Vec2f0(0), drag0), mousedrag_index)
	diff_signal = droprepeats(const_lift(getindex, diff_signal, 1:2)) #throw away drag, tmp
	const_lift(gpu_diff_set!, point_gpu, diff_signal, direction_restriction, clampto)
	points[:visible] = lift(OR, hovering_lines, hovering_points)
	Context(line_robj, points), diff_signal
end

gpu_diff_set!(gpu_object, index_value, direction_restriction, clampto) = gpu_diff_set!(gpu_object, index_value..., direction_restriction, clampto)
function gpu_diff_set!(gpu_object, index, value, direction_restriction, clampto)
	if checkbounds(Bool, size(gpu_object), index)
        T = eltype(gpu_object)
        a = T(value.*direction_restriction)
        np = gpu_object[index] - a
		gpu_object[index] = T(np[1], clamp(np[2], clampto...))
	end
	nothing
end
immutable ClampFunctor{T} <: Base.Func{3} 
    a::T
    b::T
end
Base.call(c::ClampFunctor, elem) = clamp(elem, c.a, c.b)
Base.clamp(x::FixedVector, a, b) = map(ClampFunctor(a,b) , x)

clampU8(x::RGBA) = RGBA{U8}(ntuple(i->clamp(x.(i), 0.,1.), Val{4})...)
channel_color(channel, value) = RGBA{Float32}(ntuple(i->i==channel ? value : 0.0f0, Val{4})...)

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
        c_channel = points2f0(Float32[p.(i)*scale_factor for p in colors], range)
        c_i, diff = edit_line(c_channel, dir_restrict, (0, scale_factor), window, color=channel_color(i, 0.8f0))
        const_lift(edit_color, color_tex, colors, diff, i, Float32(scale_factor))
        push!(c, c_i)
    end
    c, color_tex
end
