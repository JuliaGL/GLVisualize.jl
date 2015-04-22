const VectorfieldDefaults = @compat Dict(
    #:primitive      => Mesh()
    :cube           => Cube(Vec3(-1), Vec3(1)),
    :colorrange     => (-1,1),
    :lightposition  => Input(Vec3(20, 20, -20)), 
    :screen         => ROOT_SCREEN, 
    :colormap       => RGBA{Ufixed8}[rgbaU8(1,0,0,1), rgbaU8(1,1,0,1), rgbaU8(0,1,0,1)]
)


function visualize(::Style{:Default}, vectorfield::Texture{Vector3{Float32}, 3}, customizations)
    data = Dict(
        :vectorfield    => vectorfield,
        :cube_from      => Vec3(first(xrange), first(yrange), first(zrange)),
        :cube_to        => Vec3(last(xrange),  last(yrange),  last(zrange)),
        :color_range    => Vec2(first(colorrange), last(colorrange)),
        :colormap       => Texture(colormap),
        :lightposition  => lightposition,
        :model          => customizations[:model]
    )
    # Depending on what the is, additional values have to be calculated
    program = TemplateProgram(
        File(shaderdir, "vectorfield.vert"), 
        File(shaderdir, "util.vert"), 
        File(shaderdir, "standard.frag"), 
        File(shaderdir, "blinnphong.frag"),
        attributes=data
    )

    robj = instancedobject(data, length(vectorfield), program, GL_TRIANGLES)
    prerender!(robj, 
        glEnable,       GL_DEPTH_TEST, 
        glDepthFunc,    GL_LEQUAL, 
        glDisable,      GL_CULL_FACE, 
        enabletransparency)
    robj
end

let texture_parameters = [
    (GL_TEXTURE_MIN_FILTER, GL_NEAREST),
    (GL_TEXTURE_MAG_FILTER, GL_NEAREST),
    (GL_TEXTURE_WRAP_S,  GL_CLAMP_TO_EDGE),
    (GL_TEXTURE_WRAP_T,  GL_CLAMP_TO_EDGE),
    (GL_TEXTURE_WRAP_R,  GL_CLAMP_TO_EDGE),
  ]
visualize(vectorfield::Array{Vector3{Float32}, 3}, s, customizations) = visualize(Texture(vectorfield, parameters=parameters), s, customizations)
end
