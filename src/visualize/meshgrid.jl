visualize_default(grid::Union(Texture{Float32, 2}, Matrix{Float32}), ::Style, kw_args...) = @compat(Dict(
    :primitive  => GLNormalMesh(Cube(Vec3(0), Vec3(0.09, 0.09, 1.0))),
    :color_ramp => RGBAU8[rgbaU8(1,0,0,1), rgbaU8(1,1,0,1), rgbaU8(0,1,0,1), rgbaU8(0,1,1,1), rgbaU8(0,0,1,1)],
    :grid_min   => Vec2(-1,-1),
    :grid_max   => Vec2(1,1),
    :norm       => Vec2(minimum(grid), maximum(grid))
))

@visualize_gen Matrix{Float32} Texture

function visualize(grid::Texture{Float32, 2}, s::Style, customizations=visualize_defaults(grid, s))
    @materialize! screen, color_ramp, primitive, model = customizations
    camera       = screen.perspectivecam
    data = merge(@compat(Dict(
        :y_scale        => grid,
        :color_ramp     => Texture(color_ramp),

        :projection     => camera.projection,
        :viewmodel      => lift(*, camera.view, model),
    )), collect_for_gl(primitive), customizations)

    program = TemplateProgram(File(shaderdir, "util.vert"), File(shaderdir, "position.vert"), File(shaderdir, "standard.frag"))
    instanced_renderobject(data, length(grid), program)
end
