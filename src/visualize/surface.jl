visualize{T <: AbstractFloat}(t::Tuple{MatTypes{T}, Range, Range}, style) = visualize((t[1], Grid(t[2], t[3])), style)


function _default{T <: AbstractFloat}(grid::MatTypes{T}, ::Style{:surface}, kw_args=Dict())
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


function visualize{T <: AbstractFloat}(grid::Texture{T, 2}, s::Style{:surface}, customizations=visualize_default(grid, s))
    @materialize grid_min, grid_max, color_norm = customizations
    data[:z] = grid

    bb = const_lift(particle_grid_bb, grid_min, grid_max, color_norm) # This is not accurate. color_norm doesn't need to reflect the real height. also it doesn't get recalculated when the texture changes.

    assemble_instanced(
        grid, data,
        "util.vert", "surface.vert", "standard.frag",
        boundingbox=bb
    )
end


#Surface from x,y,z matrices
function visualize{T <: Texture{Float32, 2}}(xyz::Tuple{T,T,T}, s::Style{:surface}, customizations=visualize_default(z, s))
    data[:x] = xyz[1]
    data[:y] = xyz[2]
    data[:z] = xyz[3]

    min_x, min_y, min_z = map(minimum, xyz)
    max_x, max_y, max_z = map(maximum, xyz)
    bb = const_lift(AABB{Float32}, min_x, min_y, min_z, max_x, max_y, max_z) # This is not accurate as it doesn't recalcute the data when something updates

    program = assemble_instanced(
        x, data,
        "util.vert", "surface2.vert", "standard.frag",
        boundingbox=bb
    )
end
