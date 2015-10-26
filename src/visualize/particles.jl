# visualize style, e.g. textual, lines, surface
# color style, e.g. dark, light
# rendering style, shaded,
#=
function Style(x)
    merge(
        visual_style(x),
        color_style(x),
        rendering_style(x),
        parameter_style(x),
        primitive_style(x)
    )
end
=#
_default{T <: Point{3}}(::VecTypes{T}, s::Style, kw_args=Dict()) = Dict(
    :primitive  => Cube{Float32}(Vec3f0(0), Vec3f0(1)),
    :color      => default(RGBA),
    :scale      => Vec3f0(0.03)
)


visualize{T <: Point{3}}(value::Union{Vector{T}, Signal{Vector{T}}}, s::Style, data=visualize_default(value, s)) =
    visualize(gl_convert(TextureBuffer, value), s, data)


visualize{T <: Vec{3}}(positions::VecTypes{T}, primitive=Cube(), data) = Particles(
    primitive,
    positions,
    data[:scale],
    data[:color],
    data[:rotation],
)
visualize{T <: Vec{2}}(positions::VecTypes{T}, primitive=Cube(), data) = Particles(
    primitive,
    positions,
    data[:scale],
    data[:color],
    data[:rotation],
)

function visualize{T <: Point{3}}(
        positions::Texture{T, 1},
        s::Style, parameters=_default(positions, s)
    )
    @materialize scale = customizations
    parameters[:positions] = positions
    assemble_instanced(
        positions, data,
        "util.vert", "particles.vert", "standard.frag",
        boundingbox=Signal(AABB{Float32}(positions, scale, AABB{Float32}(vertices(primitive))))
    )
end
