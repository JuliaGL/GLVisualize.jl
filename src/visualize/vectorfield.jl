const parameters = [
    (GL_TEXTURE_MIN_FILTER, GL_NEAREST),
    (GL_TEXTURE_MAG_FILTER, GL_NEAREST),
    (GL_TEXTURE_WRAP_S,     GL_CLAMP_TO_EDGE),
    (GL_TEXTURE_WRAP_T,     GL_CLAMP_TO_EDGE),
    (GL_TEXTURE_WRAP_R,     GL_CLAMP_TO_EDGE),
]

const Defaults = @compat Dict(
    #:primitive      => Mesh()
    :cube           => Cube(Vec3(-1), Vec3(1)),
    :colorrange     => (-1,1),
    :lightposition  => Input(Vec3(20, 20, -20)), 
    :screen         => ROOT_SCREEN, 
    :colormap       => RGBA{Ufixed8}[rgbaU8(1,0,0,1), rgbaU8(1,1,0,1), rgbaU8(0,1,0,1)]
)
function visualize(style::Style{:Default}, vectorfield::Texture{Vector3{Float32}, 3}, customizations)
    primitive   = pop!(customizations, :primitive)
    model       = pop!(customizations, :model)
    cube        = pop!(customizations, :cube)
    camera      = pop!(customizations, :screen).perspectivecam

    data = merge(Dict(
        :vectorfield    => vectorfield,
        :cube_from      => Vec3(first(xrange), first(yrange), first(zrange)),
        :cube_to        => Vec3(last(xrange),  last(yrange),  last(zrange)),
        :projection     => camera.projection,
        :view           => camera.view,
        :model          => model,

    ), customizations)
    # Depending on what the is, additional values have to be calculated
    program = TemplateProgram(File(shaderdir, "vectorfield.vert"), File(shaderdir, "phongblinn.frag"), attributes=data)
    robj    = instancedobject(data, length(vectorfield), program, GL_TRIANGLES)
    
    prerender!(robj, 
        glEnable,     GL_DEPTH_TEST, 
        glDepthFunc,  GL_LEQUAL, 
        glDisable,    GL_CULL_FACE, 
        enabletransparency)
    robj
end
