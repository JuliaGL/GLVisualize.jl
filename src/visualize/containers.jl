
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




function visualize{T <: Pair}(
        dict::Union{Vector{T}, Dict}, s::Style, data::Dict
    )
    lines = Point2f0[]
    screen_w = get(data, :width, 100mm)
    text_size = get(data, :text_scale, 2mm)
    labels = String[]
    glyph_scale = GLVisualize.glyph_scale!('X')
    pos = 1mm
    scale = text_size ./ glyph_scale
    widget_text = scale .* 1.2f0
    glyph_height = round(Int, glyph_scale[2]*scale[2])
    atlas = GLVisualize.get_texture_atlas()
    font = GLVisualize.defaultfont()
    textpositions = Point2f0[]
    robjs = []
    for (k, v) in dict
        label = string(k)
        vis = visualize(v, s, data)
        bb = value(boundingbox(vis))
        height = widths(bb)[2]
        mini = minimum(bb)
        to_origin = -Vec3f0(mini[1], mini[2], 0)
        GLAbstraction.translate!(vis, Vec3f0(2mm, pos, 0) + to_origin)
        pos += round(Int, height) + 1mm
        push!(labels, label)
        append!(textpositions,
            GLVisualize.calc_position(label, Point2f0(1mm, pos), scale, font, atlas)
        )
        pos += glyph_height + 4mm
        push!(lines, Point2f0(0, pos-2mm), Point2f0(screen_w, pos-2mm))
        push!(robjs, vis)
    end
    label_vis = visualize(
        join(labels), position = textpositions,
        color = RGBA{Float32}(0.8, 0.8, 0.8, 1.0),
        relative_scale = scale
    )
    line_vis = visualize(
        lines, :linesegment, thickness=0.25mm, color=RGBA{Float32}(0.9, 0.9, 0.9, 1.0)
    )
    Context(label_vis, line_vis, robjs...)
end
