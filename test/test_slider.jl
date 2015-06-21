using GLVisualize, Reactive, GeometryTypes, GLAbstraction

drag_x(drag_id) = drag_id[1][1]

printforslider(x) 	= @sprintf("%0.5f", x)[1:5]
num2glstring(x) 	= GLVisualize.process_for_gl(printforslider(x))


function vizzedit(x, inputs)
	vizz 			= visualize(printforslider(x))
	drag 			= inputs[:mousedragdiff_objectid]
	is_num(drag_id) = drag_id[2][1] == vizz.id
	slide_addition 	= lift(drag_x, filter(is_num, (Vec2(0), Vector2(0), Vector2(0)), drag))
	haschanged 		= foldl(t0,t1 -> t0==t1)
	new_num 		= foldl(+, x, lift(/,slide_addition, 500.0))

	new_num_gl 		= lift(num2glstring, new_num)
	lift(update!, vizz[:glyphs].buffer, new_num_gl)
	return new_num, vizz
end

new_num, vizz = vizzedit(0.0, GLVisualize.ROOT_SCREEN.inputs)
view(vizz)
renderloop()


