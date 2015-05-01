
visualize_default(::Union(Texture{Point3{Float32}, 2}, Array{Point3{Float32}, 2}), ::Style, kw_args...) = @compat(Dict(
    :primitive      => GLNormalMesh(Cube(Vec3(0), Vec3(1))),
    :particle_color => RGBA(1f0, 0f0, 0f0, 1f0),
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
    instanced_renderobject(data, length(positions), program, Input(AABB(gpu_data(positions))))
end


