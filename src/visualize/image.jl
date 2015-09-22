visualize_default{T <: Colorant}(image::Union{Texture{T, 2}, Matrix{T}}, ::Style, kw_args=Dict()) = Dict(
    :primitive        => GLUVMesh2D(Rectangle{Float32}(0f0,0f0,size(image)...)),
    :preferred_camera => :orthographic_pixel
)

visualize_default(image::Images.AbstractImage, s::Style, kw_args=Dict()) = visualize_default(image.data, s, kw_args...)

visualize{T <: Colorant}(img::Array{T, 2}, s::Style, customizations=visualize_default(img, s)) =
    visualize(Texture(img), s, customizations)


function visualize{T <: Colorant}(img::Signal{Array{T, 2}}, s::Style, customizations=visualize_default(img.value, s))
    tex = Texture(img.value)
    lift(update!, tex, img)
    visualize(tex, s, customizations)
end

visualize(img::Images.AbstractImage, s::Style, customizations=visualize_default(img, s)) =
    visualize(img.data, s, customizations)

function visualize{T <: Colorant}(img::Texture{T, 2}, s::Style, data=visualize_default(img, s))
    @materialize! primitive = data
    data[:image] = img
    merge!(data, collect_for_gl(primitive))
    assemble_std(
        img, data,
        "uv_vert.vert", "texture.frag",
        boundingbox=Input(AABB{Float32}(Vec3f0(0), Vec3f0(size(img)...,0)))
    )
end
