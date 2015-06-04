
visualize_default{T <: Real}(::Union(Texture{Point2{T}, 2}, Array{Point2{T}, 2}), ::Style, kw_args...) = @compat(Dict(
    :primitive      => GLUVMesh2D(Rectangle(0f0, 0f0, 19f0,32f0)),
    :particle_color => RGBA(1f0, 0f0, 0f0, 1f0),
))


function visualize{T <: Real}(positions::Texture{Point2{T}, 2}, s::Style, customizations=visualize_default(positions, s))
    @materialize! screen, primitive, model = customizations
    camera = screen.orthographiccam
    data = merge(@compat(Dict(
        :positions           => positions,
        :projectionviewmodel => lift(*, camera.projectionview, model),
    )), collect_for_gl(primitive), customizations)

    program = TemplateProgram(File(shaderdir, "util.vert"), File(shaderdir, "particles2D.vert"), File(shaderdir, "distance_shape.frag"))
    instanced_renderobject(data, length(positions), program)
end


