
const ParticleDefaults = @compat(Dict(
    :primitive  => GLNormalMesh(Cube(Vec3(0), Vec3(0.09, 0.09, 1.0))),
    :screen     => ROOT_SCREEN, 
    :model      => Input(eye(Mat4)),
    :color_ramp => RGBAU8[rgbaU8(1,0,0,1), rgbaU8(1,1,0,1), rgbaU8(0,1,0,1), rgbaU8(0,1,1,1), rgbaU8(0,0,1,1)],
    :light      => Input(Vec3[Vec3(1.0,1.0,1.0), Vec3(0.1,0.1,0.1), Vec3(0.9,0.9,0.9), Vec4(20,20,20,1)]),
    :grid_min   => Vec2(-1,-1),
    :grid_max   => Vec2(1,1)
))

function visualize(s::Style{:Default}, grid::Matrix{Float32}, 
        customizations=ParticleDefaults, norm=Vec2(minimum(grid), maximum(grid)))
    @materialize! screen, color_ramp, primitive, model = customizations
    camera       = screen.perspectivecam
    data = merge(@compat(Dict(

        :y_scale        => Texture(grid),
        :color_ramp     => Texture(color_ramp),

        :projection     => camera.projection,
        :viewmodel      => lift(*, model, camera.view),
        :norm           => norm

    )), collect_for_gl(primitive), customizations)

    program = TemplateProgram(File(shaderdir, "util.vert"), File(shaderdir, "position.vert"), File(shaderdir, "standard.frag"))
    robj    = instancedobject(data, length(grid), program, GL_TRIANGLES)

    prerender!(robj, 
        glEnable,       GL_DEPTH_TEST, 
        glDepthFunc,    GL_LEQUAL, 
        glDisable,      GL_CULL_FACE, 
        enabletransparency)
    robj
end




const SurfDefaults = @compat(Dict(
    :primitive  => GLMesh2D(Rectangle(0f0,0f0,1f0,1f0)),
    :screen     => ROOT_SCREEN, 
    :model      => Input(eye(Mat4)),
    :color_ramp => RGBAU8[rgbaU8(1,0,0,1), rgbaU8(1,1,0,1), rgbaU8(0,1,0,1), rgbaU8(0,1,1,1), rgbaU8(0,0,1,1)],
    :light      => Input(Vec3[Vec3(1.0,1.0,1.0), Vec3(0.1,0.1,0.1), Vec3(0.9,0.9,0.9), Vec4(20,20,20,1)]),
    :grid_min   => Vec2(-1,-1),
    :grid_max   => Vec2(1,1)
))

export surf
function surf(s::Style{:Default}, grid::Matrix{Float32}, 
        customizations=SurfDefaults, norm=Vec2(minimum(grid), maximum(grid)), scale=Vec3((1f0 ./[size(grid)...])..., 1f0))

    @materialize! screen, color_ramp, primitive, model = customizations
    @materialize grid_min, grid_max = customizations
    camera       = screen.perspectivecam
    normal       = map(grid) do x
        Vec3(0,0,1)
    end
    grid_length = grid_max - grid_min
    data = merge(@compat(Dict(

        :z              => Texture(grid),
        :normal         => Texture(normal),
        :color_ramp     => Texture(color_ramp),

        :projection     => camera.projection,
        :viewmodel      => lift(*, model, camera.view),
        :norm           => norm,
        :scale          => scale.*Vec3(grid_length..., 1f0)

    )), collect_for_gl(primitive), customizations)

    program = TemplateProgram(File(shaderdir, "util.vert"), File(shaderdir, "surf.vert"), File(shaderdir, "standard.frag"))
    robj    = instancedobject(data, length(grid), program, GL_TRIANGLES)

    prerender!(robj, 
        glEnable,       GL_DEPTH_TEST, 
        glDepthFunc,    GL_LEQUAL, 
        glDisable,      GL_CULL_FACE, 
        enabletransparency)
    robj
end


const PositionDefaults = @compat(Dict(
    :primitive      => GLNormalMesh(Cube(Vec3(0), Vec3(0.01, 0.01, 0.01))),
    :screen         => ROOT_SCREEN, 
    :model          => Input(eye(Mat4)),
    :particle_color => RGBA(1f0, 0f0, 0f0, 1f0),
    :light          => Input(Vec3[Vec3(1.0,1.0,1.0), Vec3(0.1,0.1,0.1), Vec3(0.9,0.9,0.9), Vec4(20,20,20,1)]),
))

function visualize(positions::Union(Matrix{Point3{Float32}}, Signal{Matrix{Point3{Float32}}}), s=Style{:Default}(); kw_args...) 
    visualize(s, positions, merge(PositionDefaults, Dict{Symbol, Any}(kw_args)))
end
function visualize(s::Style{:Default}, positions_s::Signal{Matrix{Point3{Float32}}}, customizations=PositionDefaults)
    positions = Texture(positions_s.value)
    lift(update!, Input(positions), positions_s)
    visualize(s, positions, customizations)
end

visualize(s::Style{:Default}, positions::Matrix{Point3{Float32}}, customizations=PositionDefaults) =
    visualize(s, Texture(positions), customizations)

function visualize(s::Style{:Default}, positions::Texture{Point3{Float32}, 2}, customizations=PositionDefaults)

    @materialize! screen, primitive, model = customizations
    camera = screen.perspectivecam
    data = merge(@compat(Dict(
        :positions       => positions,
        :projection      => camera.projection,
        :viewmodel       => lift(*, model, camera.view),
    )), collect_for_gl(primitive), customizations)

    program = TemplateProgram(File(shaderdir, "util.vert"), File(shaderdir, "particles.vert"), File(shaderdir, "standard.frag"))
    robj    = instancedobject(data, length(positions), program, GL_TRIANGLES)

    prerender!(robj, 
        glEnable,       GL_DEPTH_TEST, 
        glDepthFunc,    GL_LEQUAL, 
        glDisable,      GL_CULL_FACE, 
        enabletransparency)
    robj
end


