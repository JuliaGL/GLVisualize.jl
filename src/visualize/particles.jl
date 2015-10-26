visualize_default{T <: Point{3}}(::VecTypes{T}, s::Style, kw_args=Dict()) = Dict(
    :primitive  => GLNormalMesh(Cube{Float32}(Vec3f0(0), Vec3f0(1))),
    :color      => default(RGBA),
    :scale      => Vec3f0(0.03)
)

visualize{T <: Point{3}}(
        value::Union{Vector{T}, Signal{Vector{T}}},
        s::Style, parameters=visualize_default(value, s)) =
    visualize(texture_buffer(value), s, parameters)



function visualize{T}(
        positions::Texture{Point{3, T}, 1},
        s::Style, parameters=visualize_default(positions, s)
    )
    @materialize scale = customizations
    parameters[:positions] = positions
    assemble_instanced(
        positions, data,
        "util.vert", "particles.vert", "standard.frag",
        boundingbox=Signal(AABB{Float32}(positions, scale, AABB{Float32}(vertices(primitive))))
    )
end
