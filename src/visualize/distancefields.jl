visualize_default(distancefield::Union(Texture{Float32, 2}, Array{Float32, 2}), ::Style{:distancefield}, kw_args...) = @compat(Dict(
    :color          => RGBA(1f0, 1f0, 1f0, 1f0),
    :primitive      => GLUVMesh2D(Rectangle{Float32}(0f0,0f0,size(distancefield)...))
))

@visualize_gen Array{Float32, 2} Texture Style

function visualize(distancefield::Texture{Float32, 2}, s::Style{:distancefield}, customizations=visualize_default(positions, s))
    @materialize! primitive = customizations
    data = merge(@compat(Dict(
        :distancefield       => distancefield,
    )), collect_for_gl(primitive), customizations)

    program = TemplateProgram(
        File(shaderdir, "uv_vert.vert"), 
        File(shaderdir, "distancefield.frag")
    )
    std_renderobject(data, program)
end


