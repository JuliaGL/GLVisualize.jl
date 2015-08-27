visualize_default(::Array, ::Style, kw_args...) = Dict(
    :gap 	=> Input(Vec3f0(0.1, 0.1, 0.0)),
   	:scale 	=> Vec3f0(1.0, 1.0, 1.0)
)

max_xyz_inv(width, xmask=0, ymask=0, zmask=0) = 1f0/max(width[1]*xmask, width[2]*ymask , width[3]*zmask)

function grid_translation(scale, model_scale, bb, model, i=1, j=1, k=1)
	translationmatrix(Vec3f0(i-1, j-1, k-1).*scale)*scalematrix(model_scale*scale)*translationmatrix(-minimum(bb))*model
end

function visualize{N}(grid::Array{RenderObject, N}, s::Style, customizations=visualize_default(grid, s))
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


