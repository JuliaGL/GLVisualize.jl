GLAbstraction.gl_convert(img::Images.Image) = gl_convert(Images.data(img))

_default{T <: Colorant, X}(main::Images.Image{T, 2, X}, s::Style, d::Dict) = _default(Images.data(main), s, d)
_default{T <: Colorant, X}(main::Signal{Images.Image{T, 2, X}}, s::Style, d::Dict) = _default(const_lift(Images.data, main), s, d)


_default{T <: Colorant}(main::MatTypes{T}, ::Style, data::Dict) = @gen_defaults! data begin
    image                 = main
    primitive::GLUVMesh2D = SimpleRectangle{Float32}(0f0, 0f0, size(main)...)
    boundingbox           = GLBoundingBox(primitive)
    preferred_camera      = :orthographic_pixel
    shader                = GLVisualizeShader("uv_vert.vert", "texture.frag")
end

_default{T <: Intensity}(main::MatTypes{T}, s::Style, data::Dict) = @gen_defaults! data begin
    intensity             = main
    color                 = default(Vector{RGBA{U8}},s)
    primitive::GLUVMesh2D = SimpleRectangle{Float32}(0,0,size(main)...)
    color_norm	          = Vec2f0(0, 1)
    boundingbox 	      = GLBoundingBox(primitive)
    shader                = GLVisualizeShader("uv_vert.vert", "intensity.frag")
    preferred_camera      = :orthographic_pixel
end

_default{T <: AbstractFloat}(main::MatTypes{T}, ::style"distancefield", data::Dict) = @gen_defaults! data begin
    distancefield          = main
    color                  = default(RGBA, s)
    primitive::GLUVMesh2D  = SimpleRectangle{Float32}(0f0,0f0, size(distancefield)...)
    preferred_camera       = :orthographic_pixel
    shader                 = GLVisualizeShader("uv_vert.vert", "distance_shape.frag")
end
