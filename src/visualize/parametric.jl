visualize_default(::Shader, ::Style, kw_args=Dict()) = Dict(
    :color            => default(RGBA),
    :primitive        => GLUVMesh2D(Rectangle{Float32}(0f0,0f0,1f0, 1f0)),
    :preferred_camera => :orthographic_pixel
)


function visualize(func::Shader, s::Style, data=visualize_default(func, s))
    @materialize! primitive = data
    merge!(data, collect_for_gl(primitive))
    shader = GLVisualizeShader("parametric.vert", "parametric.frag", attributes=data, view=Dict(
        "function" => bytestring(func.source)
    ))
    std_renderobject(data, shader, Signal(AABB{Float32}(vertices(primitive))))
end
