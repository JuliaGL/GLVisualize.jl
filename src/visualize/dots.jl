visualize_default{T <: Point{3}}(::Vector{T}, ::Style{:dots}, kw_args=Dict()) = Dict(
    :color      => default(RGBA),
    :point_size => 1f0
)

visualize{T}(x::Vector{Point{3, T}}, s::Style{:dots}, data=visualize_default(positions, s)) =
    visualize(gl_convert(GLBuffer, x), s, data)


function visualize{T}(
        positions::GLBuffer{Point{3, T}},
        s::Style{:dots},
        parameters=visualize_default(positions, s)
    )
    @materialize! point_size = parameters
    parameters[:vertex] = positions
    robj = assemble_std(
        positions, parameters,
        "dots.vert", "dots.frag",
        primitive=GL_POINTS
    )
    prerender!(robj, glPointSize, point_size)
    robj
end
