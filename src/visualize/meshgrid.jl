function visualize_default(grid::Union(Texture{Float32, 2}, Matrix{Float32}), ::Style, kw_args=Dict())
    grid_min    = get(kw_args, :grid_min, Vec2f0(-1, -1))
    grid_max    = get(kw_args, :grid_max, Vec2f0( 1,  1))
    grid_length = grid_max - grid_min
    scale = Vec3f0((1f0 ./[size(grid)...])..., 1f0).* Vec3f0(grid_length..., 1f0)
    return Dict(
        :primitive  => GLNormalMesh(Cube(Vec3f0(0), Vec3f0(1.0))),
        :color      => RGBAU8[rgbaU8(1,0,0,1), rgbaU8(1,1,0,1), rgbaU8(0,1,0,1), rgbaU8(0,1,1,1), rgbaU8(0,0,1,1)],
        :grid_min   => grid_min,
        :grid_max   => grid_max,
        :scale      => scale,
        :norm       => Vec2f0(minimum(grid), maximum(grid))
    )
end
@visualize_gen Matrix{Float32} Texture Style

function visualize(grid::Texture{Float32, 2}, s::Style, customizations=visualize_default(grid, s))
    @materialize! color, primitive = customizations
    @materialize grid_min, grid_max, norm = customizations
    data = merge(Dict(
        :y_scale => grid,
        :color   => Texture(color),
    ), collect_for_gl(primitive), customizations)
    assemble_instanced(
        grid, data,
        "util.vert", "meshgrid.vert", "standard.frag",
        boundingbox=lift(particle_grid_bb, grid_min, grid_max, norm)
    )
end
