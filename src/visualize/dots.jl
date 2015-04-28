
visualize_default(::Union(GLBuffer{Point3{Float32}}, Array{Point3{Float32}, 1}), ::Style{:dots}, kw_args...) = @compat(Dict(
    :particle_color => RGBAU8[rgbaU8(1,0,0,1)],
    :point_size     => 1f0
))

@visualize_gen Array{Point3{Float32}, 1} GLBuffer

function visualize(positions::GLBuffer{Point3{Float32}}, s::Style{:dots}, customizations=visualize_default(positions, s))
    @materialize! screen, model, particle_color, point_size = customizations
    camera = screen.perspectivecam
    data = merge(@compat(Dict(
        :vertex              => positions,
        :particle_color      => Texture(particle_color),
        :projectionviewmodel => lift(*, camera.projectionview, model),
    )), customizations)

    program = TemplateProgram(File(shaderdir, "dots.vert"), File(shaderdir, "dots.frag"))
    robj = std_renderobject(data, program, primitive=GL_POINTS)
    prerender!(robj, glPointSize, point_size)
    robj
end


