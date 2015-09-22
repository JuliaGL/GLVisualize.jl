function visualize_default{T <: Colorant}(image::Union{Texture{T, 1}, Vector{T}}, ::Style, kw_args=Dict())
    dimension = get(kw_args, :dimension, Rectangle(0f0,0f0,40f0, 180f0))
    Dict(
        :primitive        => GLUVMesh2D(dimension),
        :preferred_camera => :orthographic_pixel
    )
end
visualize_default(image::Images.AbstractImage, s::Style, kw_args=Dict()) = visualize_default(image.data, s, kw_args...)

visualize{T <: Colorant}(img::Array{T, 1}, s::Style, customizations=visualize_default(img, s)) =
    visualize(Texture(img), s, customizations)


function visualize{T <: Colorant}(img::Signal{Array{T, 1}}, s::Style, customizations=visualize_default(img.value, s))
    tex = Texture(img.value)
    lift(update!, tex, img)
    visualize(tex, s, customizations)
end

visualize(img::Images.AbstractImage, s::Style, customizations=visualize_default(img, s)) =
    visualize(img.data, s, customizations)

function visualize{T <: Colorant}(img::Texture{T, 1}, s::Style, data=visualize_default(img, s))
    @materialize! primitive = data
    data[:image] = img
    merge!(data, collect_for_gl(primitive))
    assemble_std(
        vertices(primitive), data,
        "uv_vert.vert", "texture.frag",
    )
end
