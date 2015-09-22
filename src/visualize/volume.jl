visualize_default(::Union{Array{Float32, 3}, Texture{Float32, 3}}, ::Style, kw_args...) = Dict(
    :hull                   => GLUVWMesh(Cube{Float32}(Vec3f0(0), Vec3f0(1))),
    :light_position         => Vec3f0(0.25, 1.0, 3.0),
    :color                  => RGBA(0.9f0, 0.0f0, 0.2f0, 1f0),
    :light_intensity        => Vec3f0(15.0),
    :isovalue               => 0.5f0,
    :absorption             => 1f0,
    :algorithm              => Cint(3),
)

visualize_default(::Union{Array{Float32, 3}, Texture{Float32, 3}}, ::Style{:mip}, kw_args...) = Dict(
    :hull                   => GLUVWMesh(Cube{Float32}(Vec3f0(0), Vec3f0(1))),
    :light_position         => Vec3f0(0.25, 1.0, 3.0),
    :light_intensity        => Vec3f0(15.0),
    :algorithm              => Cint(3),
    :color                  => RGBA(0.9f0, 0.0f0, 0.2f0, 1f0),
)
visualize_default(::Union{Array{Float32, 3}, Texture{Float32, 3}}, ::Style{:iso}, kw_args...) = Dict(
    :hull                   => GLUVWMesh(Cube{Float32}(Vec3f0(0), Vec3f0(1))),
    :light_position         => Vec3f0(0.25, 1.0, 3.0),
    :light_intensity        => Vec3f0(15.0),
    :isovalue               => 0.5f0,
    :algorithm              => Cint(2),
    :color                  => RGBA(0.9f0, 0.0f0, 0.2f0, 1f0),
)
visualize_default(::Union{Array{Float32, 3}, Texture{Float32, 3}}, ::Style{:absorption}, kw_args...) = Dict(
    :hull                   => GLUVWMesh(Cube{Float32}(Vec3f0(0), Vec3f0(1))),
    :light_position         => Vec3f0(0.25, 1.0, 3.0),
    :light_intensity        => Vec3f0(15.0),
    :absorption             => 1f0,
    :algorithm              => Cint(1),
)

@visualize_gen Array{Float32, 3} Texture Style

to_modelspace(x, model) = Vec3f0(inv(model)*Vec4f0(x...,1))
    
function visualize(intensities::Texture{Float32, 3}, s::Style, customizations=visualize_default(intensities, s))
    @materialize! hull = customizations # pull out variables to avoid duplications
    customizations[:intensities] = intensities
    data   = merge(customizations, collect_for_gl(hull))
    shader = assemble_std(
        hull.vertices, data,
        "volume.vert", "volume.frag",
    )
end
