Base.minimum(t::Texture) = minimum(gpu_data(t))
Base.maximum(t::Texture) = maximum(gpu_data(t))

function visualize_default(grid::Union(Texture{Float32, 2}, Matrix{Float32}), ::Style{:surface}, kw_args...) 
    grid_min    = get(kw_args[1], :grid_min, Vec2(-1, -1))
    grid_max    = get(kw_args[1], :grid_max, Vec2( 1,  1))
    grid_length = grid_max - grid_min
    scale = Vec3((1f0 ./[size(grid)...])..., 1f0)
    @compat(Dict(
        :primitive  => GLMesh2D(Rectangle(0f0,0f0,1f0,1f0)),
        :color_ramp => RGBAU8[rgbaU8(1,0,0,1), rgbaU8(1,1,0,1), rgbaU8(0,1,0,1), rgbaU8(0,1,1,1), rgbaU8(0,0,1,1)],
        :grid_min   => grid_min,
        :grid_max   => grid_max,
        :color_norm => Vec2(minimum(grid), maximum(grid)), 
        :scale      => scale .* Vec3(grid_length..., 1f0)
    ))
end

function visualize(grid::Texture{Float32, 2}, s::Style{:surface}, customizations=visualize_defaults(grid, s))
    println("ima here")
    @materialize! screen, color_ramp, primitive, model = customizations
    camera       = screen.perspectivecam
    data = merge(@compat(Dict(
        :z              => grid,
        :color_ramp     => Texture(color_ramp),

        :projection     => camera.projection,
        :viewmodel      => lift(*, camera.view,model),
    )), collect_for_gl(primitive), customizations)

    program = TemplateProgram(File(shaderdir, "util.vert"), File(shaderdir, "surface.vert"), File(shaderdir, "standard.frag"))
    instanced_renderobject(data, length(grid), program)
end

