function visualize_default{T}(particles::Union(Texture{Point3{T}, 2}, Texture{Point3{T}, 1}, Vector{Point3{T}}, Array{Point3{T}, 2}), s::Style, kw_args...)
    #color = get(kw_args[1], :color, RGBA(1f0, 0f0, 0f0, 1f0))
    #delete!(kw_args[1], :color)
    color = texture_or_scalar(RGBA(1f0, 0f0, 0f0, 1f0))
    Dict(
        :primitive  => GLNormalMesh(Cube(Vec3(0), Vec3(1))),
        :color      => color,
        :scale      => Vec3(0.03)
    )
end


@visualize_gen Array{Point3{Float32},2} Texture Style

function visualize(locations::Signal{Vector{Point3{Float32}}}, s::Style, customizations=visualize_default(locations, s))
    v2d = lift(to2d, locations)
    tex = Texture(v2d.value)
    lift(update!, tex, v2d)
    visualize(tex, s, customizations)
end
visualize{T}(locations::Vector{Point3{T}}, s::Style, customizations=visualize_default(locations, s)) = 
    visualize(Texture2D(locations), s, customizations)

function visualize{T}(positions::Texture{Point3{T}, 1}, s::Style, customizations=visualize_default(positions, s))
    @materialize! screen, primitive, model = customizations
    camera = screen.perspectivecam
    data = merge(Dict(
        :positions       => positions,
        :projection      => camera.projection,
        :viewmodel       => lift(*, camera.view, model),
    ), collect_for_gl(primitive), customizations)

    program = TemplateProgram(
        File(shaderdir, "util.vert"), 
        File(shaderdir, "particles.vert"), 
        File(shaderdir, "standard.frag"), attributes=data)
    bb = Input(AABB(gpu_data(positions)))
    instanced_renderobject(data, length(positions), program, bb)
end


