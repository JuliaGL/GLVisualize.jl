typealias VolumeElTypes Union{Colorant, AbstractFloat}

_default{T <: VolumeElTypes}(a::VolumeTypes{T}, s::Style{:iso}, kw_args=Dict()) = merge(
    visualize_default(a, Style{:default}(), kw_args), Dict(
        :isovalue => 0.5f0, 
        :algorithm  => Cint(2)
))

_default{T <: VolumeElTypes}(a::VolumeTypes{T}, s::Style{:absorption}, kw_args=Dict()) = merge(
    visualize_default(a, Style{:default}(), kw_args), Dict(
        :absorption => 1f0, 
        :algorithm  => Cint(1)
))

function _default{T <: VolumeElTypes, X}(img::Images.Image{T, 3, X}, ::Style, kw_args=Dict())
    dims = Vec3f0(1)
    if haskey(img.properties,"pixelspacing")
        spacing = Vec3f0(map(float, img.properties["pixelspacing"]))
        pdims   = Vec3f0(size(img))
        dims    = pdims .* spacing
        dims    = dims/maximum(dims)
    end
    data = merge(Dict(:dimensions=>dims), kw_args)
    visualize_default(img.data, Style{:default}(), data)
end
function _default{T <: VolumeElTypes}(vol::VolumeTypes{T}, s::Style, kw_args=Dict())
    dims = get!(kw_args, :dimensions, Vec3f0(1))
    Dict(
        :hull             => GLUVWMesh(Cube{Float32}(Vec3f0(0), dims)),
        :light_position   => Vec3f0(0.25, 1.0, 3.0),
        :color            => default(Vector{RGBA}, s),
        :light_intensity  => Vec3f0(15.0),
        :algorithm        => Cint(3),
        :color_norm       => Vec2f0(minimum(vol), maximum(vol))
    )
end


visualize{T <: VolumeElTypes, X}(img::Images.Image{T, 3, X}, s::Style, data=visualize_default(img, s)) = 
    visualize(gl_convert(img.data), s, data)

function visualize{T <: Union{Colorant, AbstractFloat}}(intensities::Texture{T, 3}, s::Style, data=visualize_default(intensities, s))
    @materialize! hull = data # pull out variables to avoid duplications
    data[:intensities] = intensities
    data = merge(data, collect_for_gl(hull))
    robj = assemble_std(
        hull.vertices, data,
        "util.vert", "volume.vert", "volume.frag",
    )
    prerender!(robj,
        glEnable,   GL_CULL_FACE,
        glCullFace, GL_FRONT,
    )
    robj
end
