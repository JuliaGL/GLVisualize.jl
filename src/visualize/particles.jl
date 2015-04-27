visualize_defaults(grid::Union(Texture{Float32, 2}, Matrix{Float32}), ::Style) = @compat(Dict(
    :primitive  => GLNormalMesh(Cube(Vec3(0), Vec3(0.09, 0.09, 1.0))),
    :screen     => ROOT_SCREEN, 
    :model      => Input(eye(Mat4)),
    :color_ramp => RGBAU8[rgbaU8(1,0,0,1), rgbaU8(1,1,0,1), rgbaU8(0,1,0,1), rgbaU8(0,1,1,1), rgbaU8(0,0,1,1)],
    :light      => Input(Vec3[Vec3(1.0,1.0,1.0), Vec3(0.1,0.1,0.1), Vec3(0.9,0.9,0.9), Vec4(20,20,20,1)]),
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
        :viewmodel      => lift(*, model, camera.view),
    )), collect_for_gl(primitive), customizations)

    program = TemplateProgram(File(shaderdir, "util.vert"), File(shaderdir, "position.vert"), File(shaderdir, "standard.frag"))
    instanced_renderobject(data, length(grid), program)
end





function visualize_default(grid::Union(Texture{Float32, 2}, Matrix{Float32}), ::Style{:surface}) 
    grid_length = grid_max - grid_min
    scale = Vec3((1f0 ./[size(grid)...])..., 1f0)
    @compat(Dict(
        :primitive  => GLMesh2D(Rectangle(0f0,0f0,1f0,1f0)),
        :screen     => ROOT_SCREEN, 
        :model      => Input(eye(Mat4)),
        :color_ramp => RGBAU8[rgbaU8(1,0,0,1), rgbaU8(1,1,0,1), rgbaU8(0,1,0,1), rgbaU8(0,1,1,1), rgbaU8(0,0,1,1)],
        :light      => Input(Vec3[Vec3(1.0,1.0,1.0), Vec3(0.1,0.1,0.1), Vec3(0.9,0.9,0.9), Vec4(20,20,20,1)]),
        :grid_min   => Vec2(-1,-1),
        :grid_max   => Vec2(1,1),
        :norm       => Vec2(minimum(grid), maximum(grid)), 
        :scale      => scale .* Vec3(grid_length..., 1f0)
    ))
end

function visualize(grid::Matrix{Float32}, s::Style{:surface}, customizations=visualize_defaults(grid, s))

    @materialize! screen, color_ramp, primitive, model = customizations
    @materialize grid_min, grid_max = customizations
    camera       = screen.perspectivecam
    normal       = map(grid) do x
        Vec3(0,0,1)
    end
    data = merge(@compat(Dict(
        :z              => Texture(grid),
        :normal         => Texture(normal),
        :color_ramp     => Texture(color_ramp),

        :projection     => camera.projection,
        :viewmodel      => lift(*, model, camera.view),
    )), collect_for_gl(primitive), customizations)

    program = TemplateProgram(File(shaderdir, "util.vert"), File(shaderdir, "surf.vert"), File(shaderdir, "standard.frag"))
    instanced_renderobject(data, length(grid), program)
end


visualize_default(::Union(Texture{Point3{Float32}, 2}, Array{Point3{Float32}, 2}), ::Style) = @compat(Dict(
    :primitive      => GLNormalMesh(Cube(Vec3(0), Vec3(1))),
    :screen         => ROOT_SCREEN, 
    :model          => Input(eye(Mat4)),
    :particle_color => RGBA(1f0, 0f0, 0f0, 1f0),
    :light          => Input(Vec3[Vec3(1.0,1.0,1.0), Vec3(0.1,0.1,0.1), Vec3(0.9,0.9,0.9), Vec4(20,20,20,1)]),
))


@visualize_gen Array{Point3{Float32}, 2} Texture

function visualize(positions::Texture{Point3{Float32}, 2}, s::Style, customizations=visualize_default(positions, s))
    @materialize! screen, primitive = customizations
    camera = screen.perspectivecam
    data = merge(@compat(Dict(
        :positions       => positions,
        :projection      => camera.projection,
        :viewmodel       => camera.view,
    )), collect_for_gl(primitive), customizations)

    program = TemplateProgram(File(shaderdir, "util.vert"), File(shaderdir, "particles.vert"), File(shaderdir, "standard.frag"))
    instanced_renderobject(data, length(positions), program)
end


