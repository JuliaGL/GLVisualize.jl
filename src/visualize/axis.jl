visualize_default(::AABB{Float32}, ::Style{:grid}, kw_args=Dict()) = Dict(
    :bg_colorc =>  RGBA{Float32}(0.8,0.8,0.8,1.0),
    :grid_color => RGBA{Float32}(0.9,0.9,0.9,1.0),
    :grid_thickness => Vec3f0(2), 
    :gridsteps => Vec3f0(10), 
)

function visualize(c::AABB{Float32}, ::Style{:grid}, default)
    primitive   = GLPlainMesh(c)
    data        = merge(default, collect_for_gl(primitive))
    robj        = GLVisualize.assemble_std(
        vertices(primitive), data,
        "grid.vert", "grid.frag",
        boundingbox=Input(c)
    )
    empty!(robj.prerenderfunctions)
    prerender!(robj,
        glEnable, GL_DEPTH_TEST,
        glDepthMask, GL_TRUE,
        glDepthFunc, GL_LEQUAL,
        glEnable, GL_CULL_FACE,
        glCullFace, GL_BACK,
        enabletransparency
    )
    return robj
end
