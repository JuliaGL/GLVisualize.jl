_default(::Union{GLPlainMesh, GeometryPrimitive}, ::Style{:grid}, kw_args=Dict()) = Dict(
    :color          => default(RGBA),
    :bg_colorc      => default(RGBA, s, 2),
    :grid_thickness => Vec3f0(2),
    :gridsteps      => Vec3f0(5),
)

visualize(g::GeometryPrimitive, s::Style{:grid}, data=visualize_default(g, s)) =
    visualize(GLPlainMesh(g), s, data)

function visualize(primitive::GLPlainMesh, ::Style{:grid}, data)
    merge!(data, collect_for_gl(primitive))
    robj = GLVisualize.assemble_std(
        vertices(primitive), data,
        "grid.vert", "grid.frag",
        boundingbox=Signal(c)
    )
    empty!(robj.prerenderfunctions)
    prerender!(robj,
        glEnable, GL_DEPTH_TEST,
        glDepthMask, GL_FALSE,
        glDepthFunc, GL_LEQUAL,
        glEnable, GL_CULL_FACE,
        glCullFace, GL_BACK,
        enabletransparency
    )
    return robj
end
