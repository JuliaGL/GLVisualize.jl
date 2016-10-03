
max_xyz_inv(width, xmask=0, ymask=0, zmask=0) = 1f0/max(width[1]*xmask, width[2]*ymask , width[3]*zmask)

function grid_translation(scale, model_scale, bb, model, i=1, j=1, k=1)
    translationmatrix(Vec3f0(i-1, j-1, k-1).*scale)*scalematrix(model_scale*scale)*translationmatrix(-minimum(bb))*model
end

function visualize{T <: Composable, N}(grid::Array{T, N}, s::Style, data::Dict)
    @gen_defaults! data begin
        scale    = Vec3f0(1) #axis of 3D dimension, can be signed
    end
    for ind=1:length(grid)
        robj     = grid[ind].children[]
        bb_s     = boundingbox(robj)
        w        = const_lift(widths, bb_s)
        model_scale = const_lift(max_xyz_inv, w, Vec{N, Int}(1)...)
        robj[:model] = const_lift(grid_translation, scale, model_scale, bb_s, robj[:model], ind2sub(size(grid), ind)...) # update transformation matrix
    end
    Context(grid...)
end

function list_translation(lastposition, gap, direction, bb)
    directionmask     = unit(Vec3f0, abs(direction))
    alignmask         = abs(1-directionmask)
    move2align        = (alignmask.*lastposition)-minimum(bb) #zeros direction
    move2nextposition = sign(direction)*(directionmask.*widths(bb))
    nextpos           = lastposition + move2nextposition + (directionmask.*gap)
    lastposition+move2align, nextpos
end

function visualize{T <: Composable}(list::Vector{T}, s::Style, data::Dict)
    @gen_defaults! data begin
        direction    = 2 #axis of 3D dimension, can be signed
        gap          = 0.1f0*unit(Vec3f0, abs(direction))
        lastposition = Vec3f0(0)
    end
    for elem in list
        transl_nextpos = const_lift(list_translation, lastposition, gap, direction, boundingbox(elem))
        GLAbstraction.translate!(elem, map(first, transl_nextpos))
        lastposition = map(last, transl_nextpos)
    end
    Context(list...)
end
