
visualize_default{T}(::Matrix{T}, ::Style, kw_args...) = @compat(Dict(
    :gap => Input(Vec3(0.1, 0.1, 0.0))
))

function visualize{T}(grid::Matrix{T}, s::Style, customizations=visualize_default(grid, s))
    @materialize! screen, gap, model = customizations
    grid_position    = Vec3(0,0,0)
    result      = RenderObject[]
    for x=1:size(grid, 1), y=1:size(grid, 2)
        robj = visualize(element, screen=screen, model=lift(translationmatrix, grid_position))
        bb = robj.boundingbox
    end
    result
end


