visualize_default{T <: Color}(image::Union(Texture{T, 2}, Matrix{T}), ::Style, kw_args...) = @compat(
    Dict(:primitive  => GLUVMesh2D(Rectangle{Float32}(0f0,0f0,size(image)...))))
visualize_default(image::AbstractImage, s::Style, kw_args...) = visualize_default(image.data, s, kw_args...)

visualize{T <: Color}(img::Array{T, 2}, s::Style, customizations=visualize_default(img, s)) = 
    visualize(Texture(img), s, customizations)


function visualize{T <: Color}(img::Signal{Array{T, 2}}, s::Style, customizations=visualize_default(img.value, s))
    tex = Texture(img.value)
    lift(update!, tex, img)
    visualize(tex, s, customizations)
end
visualize(img::Image, s::Style, customizations=visualize_default(img, s)) = 
    visualize(img.data, s, customizations)

function visualize{T <: Color}(img::Texture{T, 2}, s::Style, customizations=visualize_default(img, s))
    @materialize! screen, model, primitive = customizations
    camera = screen.orthographiccam
    pvm = lift(*, camera.projectionview, model)
    data = merge(@compat(Dict(
        :image               => img,
        :projectionviewmodel => pvm,
    )), collect_for_gl(primitive))

    fragdatalocation = [(0, "fragment_color"),(1, "fragment_groupid")]
    textureshader    = TemplateProgram(File(shaderdir, "uv_vert.vert"), File(shaderdir, "texture.frag"), attributes=data, fragdatalocation=fragdatalocation)

    obj = std_renderobject(data, textureshader, Input(AABB(Vec3(0), Vec3(size(img)...,0)))) # really not a good boundingbox.

end
