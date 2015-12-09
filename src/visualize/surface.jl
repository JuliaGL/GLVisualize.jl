visualize{T <: AbstractFloat}(t::Tuple{MatTypes{T}, Range, Range}, style) = visualize((t[1], Grid(t[2], t[3])), style)


function _default{T <: AbstractFloat}(grid::MatTypes{T}, ::Style{:surface}, kw_args::Dict)
    grid_min    = get(kw_args, :grid_min, Vec2f0(-1, -1))
    grid_max    = get(kw_args, :grid_max, Vec2f0( 1,  1))
    grid_length = grid_max - grid_min
    scale = Vec3f0((1f0 ./[size(grid)...])..., 1f0)
    Dict(
        :primitive  => GLMesh2D(SimpleRectangle(0f0,0f0,1f0,1f0)),
        :color      => default(Vector{RGBA}),
        :grid_min   => grid_min,
        :grid_max   => grid_max,
        :color_norm => Vec2f0(minimum(grid), maximum(grid)),
        :scale      => scale .* Vec3f0(grid_length..., 1f0),
    )
end
