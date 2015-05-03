visualize_default(::Union(Texture{Point2{Float32}, 2}, Array{Point2{Float32}, 2}), ::Style, kw_args...) = @compat(Dict(
    :primitive      => GLUVMesh2D(Rectangle(0f0, 0f0, 1f0, 1f0)),
    :particle_color => RGBA(1f0, 0f0, 0f0, 1f0),
))

@visualize_gen Array{Point3{Float32}, 2} Texture

function visualize(positions::Texture{Point2{Float32}, 2}, s::Style, customizations=visualize_default(positions, s))
    @materialize! screen, primitive = customizations
    camera = screen.perspectivecam
    data = merge(@compat(Dict(
        :positions       => positions,
        :projection      => camera.projection,
        :viewmodel       => camera.view,
    )), collect_for_gl(primitive), customizations)

    program = TemplateProgram(File(shaderdir, "util.vert"), File(shaderdir, "particles2D.vert"), File(shaderdir, "distance_shape.frag"))
    instanced_renderobject(data, length(positions), program, Input(AABB(gpu_data(positions))))
end


