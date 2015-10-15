float_diff(a,b) = Vec2f2(a-b)
function vizzedit{T}(points::Vector{Point{2,T}}, window)
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