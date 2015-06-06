
visualize_default{T <: Real}(::Union(Texture{Point2{T}, 2}, Array{Point2{T}, 2}, Vector{Point2{T}}), ::Style, kw_args...) = @compat(Dict(
    :primitive      => GLUVMesh2D(Rectangle(0f0, 0f0, 1f0, 1f0)),
    :color          => RGBA(1f0, 0f0, 0f0, 1f0),
    :scale          => Vec2(50)
))

function visualize(locations::Signal{Vector{Point2{Float32}}}, s::Style, customizations=visualize_default(locations, s))
    v2d = lift(to2d, locations)
    tex = Texture(v2d.value)
    lift(update!, tex, v2d)
    visualize(tex, s, customizations)
end
visualize(locations::Vector{Point2{Float32}}, s::Style, customizations=visualize_default(locations, s)) = 
    visualize(Texture2D(locations), s, customizations)

function visualize{T <: Real}(positions::Texture{Point2{T}, 2}, s::Style, customizations=visualize_default(positions, s))
    @materialize! screen, primitive, model = customizations
    camera = screen.orthographiccam
    data = merge(@compat(Dict(
        :positions           => positions,
        :projectionviewmodel => lift(*, camera.projectionview, model),
    )), collect_for_gl(primitive), customizations)

    program = TemplateProgram(
        File(shaderdir, "util.vert"), 
        File(shaderdir, "particles2D.vert"), 
        File(shaderdir, "distance_shape.frag")
    )
    bb = AABB(gpu_data(positions))
    println(bb)
    instanced_renderobject(data, length(positions), program, Input(bb))
end


