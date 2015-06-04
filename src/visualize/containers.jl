
visualize_default(::Matrix, ::Style, kw_args...) = @compat(Dict(
    :gap => Input(Vec3(0.1, 0.1, 0.0))
))

function visualize(grid::Matrix, s::Style, customizations=visualize_default(grid, s))
    @materialize! screen, gap, model = customizations
    results = map(grid) do viz_args
		trans = Input(eye(Mat4)) # get a handle to the translation matrix
		if isa(viz_args, Tuple)
			length(viz_args) < 1 && error("tried to visualize empty tuple ()")
			key_args = collect(filter(x->isa(x, Pair), viz_args))
			viz_data = collect(filter(x->!isa(x, Pair), viz_args))
			return (trans, visualize(viz_data...; key_args..., model=trans))
		end
		return (trans, visualize(viz_args, model=trans))
	end

	for i=1:size(results, 1), j=1:size(results, 2)
		model, robj = results[i,j]
		bb = robj.boundingbox.value
		width = bb.max-bb.min
		scale = 1f0/max(width.x, width.y)
		push!(model, translationmatrix(Vec3(i-1,j-1,0))*scalematrix(Vec3(scale))*translationmatrix(-bb.min)) # update transformation matrix
	end
	vec(map(last, results))
end


