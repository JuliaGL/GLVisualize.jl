visualize_default{T <: Union{Colorant, AbstractFloat}}(a::Union{Array{T, 3}, Texture{T, 3}}, s::Style{:iso}, kw_args=Dict()) = merge(
    visualize_default(a, Style{:default}(), kw_args), Dict(:isovalue => 0.5f0, :algorithm  => Cint(2))
)
visualize_default{T <: Union{Colorant, AbstractFloat}}(a::Union{Array{T, 3}, Texture{T, 3}}, s::Style{:absorption}, kw_args=Dict()) = merge(
    visualize_default(a, Style{:default}(), kw_args), Dict(:absorption => 1f0, :algorithm  => Cint(1))
)

function visualize_default{T <: Union{Colorant, AbstractFloat}, X}(img::Images.Image{T, 3, X}, ::Style, kw_args=Dict())
    dims = Vec3f0(1)
    if haskey(img.properties,"pixelspacing")
        dims = Vec3f0(map(float, img.properties["pixelspacing"]))
        dims = dims/max(dims...)
    end
    data = merge(Dict(:dimensions=>dims), kw_args)
    visualize_default(img.data, Style{:default}(), data)
end
function visualize_default{T <: Union{Colorant, AbstractFloat}}(::Union{Array{T, 3}, Texture{T, 3}}, ::Style, kw_args=Dict())
    dims = get(kw_args, :dimensions, Vec3f0(1,1,1))
    Dict(
        :dimensions             => dims,
        :hull                   => GLUVWMesh(Cube{Float32}(Vec3f0(0), dims)),
        :light_position         => Vec3f0(0.25, 1.0, 3.0),
        :color                  => RGBA(0.9f0, 0.0f0, 0.2f0, 1f0),
        :light_intensity        => Vec3f0(15.0),
        :algorithm              => Cint(3),
    )
end


@visualize_gen Array{Float32, 3} Texture Style
@visualize_gen Array{Gray{Ufixed8}, 3} Texture Style

to_modelspace(x, model) = Vec3f0(inv(model)*Vec4f0(x...,1))
    
function visualize{T <: Union{Colorant, AbstractFloat}, X}(img::Images.Image{T, 3, X}, s::Style, kw_args=visualize_default(img, s))
    visualize(map(Float32, img.data), s, kw_args)
end
function visualize{T <: Union{Colorant, AbstractFloat}}(intensities::Texture{T, 3}, s::Style, customizations=visualize_default(intensities, s))
    @materialize! hull = customizations # pull out variables to avoid duplications
    customizations[:intensities] = intensities
    data   = merge(customizations, collect_for_gl(hull))
    shader = assemble_std(
        hull.vertices, data,
        "volume.vert", "volume.frag",
    )
end
