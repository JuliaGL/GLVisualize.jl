function visualize_default(grid::Union(Texture{Float32, 2}, Matrix{Float32}), ::Style, kw_args...)
    grid_min    = get(kw_args[1], :grid_min, Vec2(-1, -1))
    grid_max    = get(kw_args[1], :grid_max, Vec2( 1,  1))
    grid_length = grid_max - grid_min
    scale = Vec3((1f0 ./[size(grid)...])..., 1f0).* Vec3(grid_length..., 1f0)
    return Dict(
        :primitive  => GLNormalMesh(Cube(Vec3(0), Vec3(1.0))),
        :color      => RGBAU8[rgbaU8(1,0,0,1), rgbaU8(1,1,0,1), rgbaU8(0,1,0,1), rgbaU8(0,1,1,1), rgbaU8(0,0,1,1)],
        :grid_min   => grid_min,
        :grid_max   => grid_max,
        :scale      => scale,
        :norm       => Vec2(minimum(grid), maximum(grid))
    )
end
@visualize_gen Matrix{Float32} Texture Style

function visualize(grid::Texture{Float32, 2}, s::Style, customizations=visualize_defaults(grid, s))
    @materialize! screen, color, primitive, model = customizations
    @materialize grid_min, grid_max, norm = customizations
    
    camera       = screen.perspectivecam
    data = merge(Dict(
        :y_scale        => grid,
        :color          => Texture(color),
        :projection     => camera.projection,
        :viewmodel      => lift(*, camera.view, model),
    ), collect_for_gl(primitive), customizations)
    program = TemplateProgram(File(shaderdir, "util.vert"), File(shaderdir, "meshgrid.vert"), File(shaderdir, "standard.frag"))
    instanced_renderobject(data, length(grid), program, lift(particle_grid_bb, grid_min, grid_max, norm))
end
