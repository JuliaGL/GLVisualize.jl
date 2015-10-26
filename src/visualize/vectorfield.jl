
#=
type Particle
::Position #-> Grid, Vol, Points2/3D
::Scale
::Rotation
::Primitive
::Color
end
=#

visualize_default{T <: Vec{3}}(::VolumeTypes{T}, ::Style, kw_args = Dict()) = Dict(
    :primitive      => Pyramid(Point{3, Float32}(0, 0,-0.5), 1f0, 0.2f0),
    :boundingbox    => AABB{Float32}(Vec3f0(-1), Vec3f0(1)),
    :color_norm     => Vec2f0(-1,1),
    :color          => default(Vector{RGBA})
)

function visualize{T <: Vec{3}}(vectorfield::Texture{T, 3}, s::Style, data=visualize_default(vectorfield, s))
    @materialize! boundingbox = customizations
    set_parameters(vectorfield, minfilter=:nearest, x_repeat=:clamp_to_edge)
    data[:vectorfield] = vectorfield
    data[:cube_min]    = minimum(boundingbox)
    data[:cube_max]    = maximum(boundingbox)
    assemble_instanced(
        vectorfield, data,
        "util.vert", "vectorfield.vert", "standard.frag",
        boundingbox=Signal(boundingbox)
    )
end


function visualize{T}(vectorfield::Array{Vec{3, T}, 3}, s::Style, customizations=visualize_default(vectorfield, s))
    _norm = map(norm, vectorfield)
    customizations[:color_norm] = Vec2f0(minimum(_norm), maximum(_norm))
    visualize(Texture(vectorfield, minfilter=:nearest, x_repeat=:clamp_to_edge), s, customizations)
end
