_default{N, T}(main::VecTypes{Point{N, T}}, s::Style, data::Dict) = _default((centered(HyperRectangle{N, Float32}), main), s, data)
function _default{T <: Vec3}(main::VolumeTypes{T}, s::Style, data::Dict)
    data[:rotation] = vec(main)
    get!(data, :color_norm) do
        _norm = map(norm, vectorfield)
        Vec2f0(minimum(_norm), maximum(_norm))
    end
    get!(data, :color, default(Vector{RGBA}))
    _default((Pyramid(Point3f0(0,0,-0.5), 1f0, 0.2f0), Grid(main)), s, data)
end

_default{Primitive <: Union{GeometryPrimitive{3}, AbstractMesh}, T <: Point}(p::Tuple{Primitive, VecTypes{T}}, s::Style, data::Dict) = @gen_defaults! data begin
    primitive::GLNormalMesh = p[1]
    color            = default(RGBA{Float32}, s) => TextureBuffer
    position         = p[2]                      => TextureBuffer
    scale            = nothing                   => TextureBuffer
    rotation         = nothing                   => TextureBuffer
    intensity        = nothing                   => TextureBuffer
    color_norm       = nothing                   => TextureBuffer
    instances        = position
    boundingbox      = GLBoundingBox(position, scale, primitive)
    shader           = GLVisualizeShader("util.vert", "particles.vert", "standard.frag")
end

_default{T <: Point}(positions::VecTypes{T}, s::style"points", data::Dict) = @gen_defaults! data begin
    vertex       = positions => GLBuffer
    point_size   = 2f0
    prerender    = +((glPointSize, point_size),)
    shader       = GLVisualizeShader("dots.vert", "dots.frag")
    gl_primitive = GL_POINTS
end


function overall_scale(stroke_width, glow_width, scale)
    final_scale = Vec2f0(scale)
    (stroke_width > 0f0) && (final_scale += stroke_width/2f0)
    (glow_width   > 0f0) && (final_scale += glow_width/2f0)
    final_scale
end
GLAbstraction.gl_convert(img::Images.Image) = gl_convert(Images.data(img))
primitive_shape(::Circle) = CIRCLE
primitive_shape(::SimpleRectangle) = RECTANGLE

primitive_scale(c::Circle) = Vec2f0(c.r)
primitive_scale(r::SimpleRectangle) = Vec2f0(r.w, r.h)

_default{Primitive <: GeometryPrimitive{2}, P <: Point}(p::Tuple{Primitive, Vector{P}}, s::Style, data::Dict) = @gen_defaults! data begin
    scale               = Vec2f0(40)          => GLBuffer
    stroke_width        = 2f0
    glow_width          = 0f0
    offset_scale        = const_lift(overall_scale, stroke_width, glow_width, scale)
    shape               = primitive_shape(p[1])
    position            = p[2]                => GLBuffer
    rotation            = nothing             => GLBuffer
    intensity           = nothing             => GLBuffer
    color_norm          = nothing             => GLBuffer

    color               = default(RGBA, s)    => GLBuffer
    stroke_color        = default(RGBA, s, 2) => GLBuffer
    glow_color          = default(RGBA, s, 3) => GLBuffer
    image               = nothing             => Texture
    distancefield       = nothing             => Texture
    transparent_picking = true
    preferred_camera    = :orthographic_pixel
    shader              = GLVisualizeShader("util.vert", "sprites.geom", "sprites.vert", "distance_shape.frag")
    gl_primitive        = GL_POINTS
end
