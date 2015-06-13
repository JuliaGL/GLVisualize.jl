
visualize_default{T <: Real}(::Union(Texture{Point2{T}, 1}, Vector{Point2{T}}), ::Style, kw_args=Dict()) = @compat(Dict(
    :primitive      => GLUVMesh2D(Rectangle(0f0, 0f0, 1f0, 1f0)),
    :color          => RGBA(1f0, 0f0, 0f0, 1f0),
    :scale          => Vec2(50, 50),
    :technique      => :circle
))

visualize(locations::Vector{Point2{Float32}}, s::Style, customizations=visualize_default(locations, s)) = 
    visualize(texture_buffer(locations), s, customizations)


function visualize{T <: Real}(
        positions::Texture{Point2{T}, 1}, 
        s::Style, customizations=visualize_default(positions, s)
    )
    @materialize! screen, primitive, model, technique = customizations
    camera = screen.orthographiccam
    data = merge(@compat(Dict(
        :positions           => positions,
        :projectionviewmodel => lift(*, camera.projectionview, model),
        :technique           => lift(to_gl_technique, technique)
    )), collect_for_gl(primitive), customizations)

    program = TemplateProgram(
        File(shaderdir, "util.vert"), 
        File(shaderdir, "particles2D.vert"), 
        File(shaderdir, "distance_shape.frag"),
        attributes=data,
        fragdatalocation=[(0, "fragment_color"), (1, "fragment_groupid")]
    )
    instanced_renderobject(data, length(positions), program)
end


