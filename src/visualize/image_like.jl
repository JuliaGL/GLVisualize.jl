_default{T <: Colorant, X}(main::Images.Image{T, 2, X}, s::Style, data::Dict) = _default(data(main), s, data)
_default{T <: Colorant, X}(main::Signal{Images.Image{T, 2, X}}, s::Style, data::Dict) = _default(const_lift(data, main), s, data)


_default{T <: Colorant}(main::MatTypes{T}, ::Style, data::Dict) = @gen_defaults! data begin
    image                 = main
    primitive::GLUVMesh2D = Rectangle(0f0, 0f0, 40f0, 180f0) 
    boundingbox           = GLBoundingBox(primitive)
    preferred_camera      = :orthographic_pixel
    shader                = GLVisualizeShader("uv_vert.vert", "texture.frag")
end

_default{T <: Intensity}(main::MatTypes{T}, s::Style, data::Dict) = @gen_defaults! data begin
    intensity             = main
    color                 = default(Vector{RGBA{U8}},s)
    primitive::GLUVMesh2D = Rectangle{Float32}(0,0,size(main)...)
    color_norm	          = Vec2f0(0, 1)
    preferred_camera      = :orthographic_pixel
    boundingbox 	      = GLBoundingBox(primitive)
    shader                = GLVisualizeShader("uv_vert.vert", "intensity.frag")
end

_default{T <: AbstractFloat}(main::MatTypes{T}, ::style"distancefield", data::Dict) = @gen_defaults! data begin
    distancefield          = main
    color                  = default(RGBA, s)
    primitive:: GLUVMesh2D = Rectangle{Float32}(0f0,0f0, size(distancefield)...) 
    preferred_camera       = :orthographic_pixel
    shader                 = GLVisualizeShader("uv_vert.vert", "distance_shape.frag")
end


