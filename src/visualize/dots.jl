function visualize_default{T}(::Vector{Point{3, T}}, s::Style{:dots}, kw_args...)
    color = get(kw_args[1], :color, default(RGBA, s))
    delete!(kw_args[1], :color)
    color = texture_or_scalar(color)
    Dict(
        :color       => color,
        :point_size  => 1f0
    )
end

@visualize_gen Vector{Point{3, Float32}} GLBuffer Style{:dots}

function visualize{T}(
        positions::GLBuffer{Point{3, T}}, 
        s::Style{:dots}, 
        data=visualize_default(positions, s)
    )
    @materialize! point_size = data
    data[:vertex] = positions
    robj = assemble_std(
        positions, data,
        "dots.vert", "dots.frag",
        primitive=GL_POINTS
    )
    prerender!(robj, glPointSize, point_size)
    robj
end


