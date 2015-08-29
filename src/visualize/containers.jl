visualize_default{T <: Composable, N}(::Array{T, N}, ::Style, kw_args...) = Dict(
    :gap 	=> Input(Vec3f0(0.1, 0.1, 0.0)),
   	:scale 	=> Vec3f0(1.0, 1.0, 1.0)
)

max_xyz_inv(width, xmask=0, ymask=0, zmask=0) = 1f0/max(width[1]*xmask, width[2]*ymask , width[3]*zmask)

function grid_translation(scale, model_scale, bb, model, i=1, j=1, k=1)
	translationmatrix(Vec3f0(i-1, j-1, k-1).*scale)*scalematrix(model_scale*scale)*translationmatrix(-minimum(bb))*model
end

function visualize{T <: Composable, N}(grid::Array{T, N}, s::Style, customizations=visualize_default(grid, s))
    @materialize! gap, model, scale = customizations
	for ind=1:length(grid)
		robj 	= grid[ind]
		bb_s 	= robj.boundingbox
		w 		= lift(width, bb_s)
		model_scale = lift(max_xyz_inv, w, Vec{N, Int}(1)...)
		robj[:model] = lift(grid_translation, scale, model_scale, bb_s, robj[:model], ind2sub(size(grid), ind)...) # update transformation matrix
	end
	vec(grid)
end

visualize_default{T <: Composable}(::Vector{T}, ::Style, kw_args...) = Dict(
    :gap 	=> 0f0,
)
y_coord(x) = x[2]
function list_translation(y_start, x_align, bb)
	w = width(bb)[2]
	x_move = x_align - minimum(bb)[1]
	translationmatrix(Vec3f0(x_move, y_start-w, 0))
end

function visualize{T <: Composable}(list::Vector{T}, s::Style, customizations=visualize_default(grid, s))
    @materialize! gap = customizations
    elem 	= first(list)
    bb_s 	= boundingbox(elem)
	y_start = lift(-, lift(y_coord, lift(getfield, bb_s, :minimum)), gap)
	x_align = lift(first, lift(minimum, bb_s))
	for elem in list[2:end]
		bb_s 		 = boundingbox(elem)
		transformation(elem, lift(list_translation, y_start, x_align, bb_s))
		y_width 	 = lift(y_coord, lift(width, bb_s))
		y_start 	 = lift(-, y_start, lift(+, y_width, gap))
	end
	Context(list...)
end