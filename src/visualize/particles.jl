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
function _default{T <: AbstractFloat}(main::MatTypes{T}, s::Style, data::Dict)
    grid = Grid(main)
    @gen_defaults! data begin
        scale_z = const_lift(vec, main)
        scale_x = step(grid.dims[1])
        scale_y = step(grid.dims[2])
    end
    _default((centered(Cube), grid), s, data)
end
function _default{T <: AbstractFloat}(main::VecTypes{T}, s::Style, data::Dict)
    grid = Grid(main)
    @gen_defaults! data begin
        scale_x = step(grid.dims[1])
        scale_y = 1f0
        scale_z = main => TextureBuffer
    end
    _default((centered(Cube), grid), s, data)
end
function _default{Primitive <: Union{GeometryPrimitive{3}, AbstractMesh}, P <: Point}(
        p::Tuple{Primitive, VecTypes{P}}, s::Style, data::Dict
    )
    @gen_defaults! data begin
        primitive::GLNormalMesh = p[1]
        color            = default(RGBA{Float32}, s) => TextureBuffer
        position         = p[2]                      => TextureBuffer
        scale            = nothing                   => TextureBuffer
        scale_z          = nothing                   => TextureBuffer
        scale_x          = nothing                   => TextureBuffer
        scale_y          = nothing                   => TextureBuffer
        rotation         = nothing                   => TextureBuffer
        intensity        = nothing                   => TextureBuffer
        color_norm       = nothing                   => Vec2f0
        instances        = position                  
        boundingbox      = GLBoundingBox(position, scale, primitive)
        shader           = GLVisualizeShader("util.vert", "particles.vert", "standard.frag")
    end
end
function _default{Primitive <: Union{GeometryPrimitive{3}, AbstractMesh}, G <: Grid}(
        p::Tuple{Primitive, G}, s::Style, data::Dict
    )
    @gen_defaults! data begin
        primitive::GLNormalMesh = p[1]
        color            = default(RGBA{Float32}, s) => TextureBuffer
        position         = p[2]                      => TextureBuffer
        scale            = nothing                   => TextureBuffer
        scale_z          = nothing                   => TextureBuffer
        scale_x          = nothing                   => TextureBuffer
        scale_y          = nothing                   => TextureBuffer

        rotation         = nothing                   => TextureBuffer
        intensity        = nothing                   => TextureBuffer
        color_norm       = nothing                   => Vec2f0
        instances        = position
        boundingbox      = GLBoundingBox(position, scale, primitive)
        shader           = GLVisualizeShader("util.vert", "particles.vert", "standard.frag")
    end
end
_default{T <: Point}(positions::VecTypes{T}, s::style"points", data::Dict) = @gen_defaults! data begin
    vertex       = positions => GLBuffer
    color        = default(RGBA{Float32}, s) => GLBuffer
    intensity    = default(RGBA{Float32}, s) => GLBuffer
    color_norm   = nothing                   => Vec2f0

    point_size   = 2f0
    prerender    = +((glPointSize, point_size),)
    shader       = GLVisualizeShader("dots.vert", "dots.frag")
    gl_primitive = GL_POINTS
end
function overall_scale(stroke_width, glow_width, scale::GPUArray)
    first(gpu_data(scale))
end
function overall_scale(stroke_width, glow_width, scale::Vector)
    first(scale)
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
primitive_shape{T}(::HyperRectangle{2,T}) = RECTANGLE
primitive_shape(x::Shape) = x

primitive_scale(c::Circle) = Vec2f0(c.r)
primitive_scale(r::SimpleRectangle) = Vec2f0(r.w, r.h)

function _default{T<:AbstractString}(main::Signal{T}, s::Style, data::Dict)
    atlas       = get_texture_atlas()
    char_id     = preserve(map(process_for_gl, main))
    t_uv        = GLBuffer(Vec4f0[atlas.attributes[id+1] for id in char_id.value])
    t_scale     = GLBuffer(Vec2f0[atlas.scale[id+1] for id in char_id.value])
    position    = GLBuffer(map(Point2f0, calc_position(char_id.value)))
    vals        = map(char_id) do cid
        update!(t_uv     , Vec4f0[atlas.attributes[id+1] for id in cid])
        update!(t_scale  , Vec2f0[atlas.scale[id+1] for id in cid])
        update!(position , map(Point2f0, calc_position(cid)))
        nothing
    end
    preserve(vals)
    @gen_defaults! data begin
        scale           = t_scale   => GLBuffer
        uv_offset_width = t_uv      => GLBuffer
        distancefield   = atlas.images
        stroke_width    = 0f0
        glow_width      = 0f0
    end
    _default((DISTANCEFIELD, position), s, data)
end
function _default{T<:AbstractString}(main::T, s::Style, data::Dict)
    char_id     = process_for_gl(main)
    atlas       = get_texture_atlas()
    t_uv        = Vec4f0[begin
        if id == Int(get_font!('\n'))
            atlas.attributes[Int(get_font!(' '))+1]
        else
            atlas.attributes[id+1] 
        end
    end for id in char_id]
    t_scale     = Vec2f0[atlas.scale[id+1] for id in char_id]
    position    = map(Point2f0, calc_position(char_id))
    @gen_defaults! data begin
        scale           = t_scale   => GLBuffer
        uv_offset_width = t_uv      => GLBuffer
        distancefield   = atlas.images
        stroke_width    = 0f0
        glow_width      = 0f0
    end
    _default((DISTANCEFIELD, position), s, data)
end


_default{Primitive <: Union{GeometryPrimitive{2}, Shape}, P <: Point}(p::Tuple{Primitive, VecTypes{P}}, s::Style, data::Dict) = @gen_defaults! data begin
    scale               = primitive_scale(p[1]) => GLBuffer
    stroke_width        = 2f0
    glow_width          = 0f0
    offset_scale        = const_lift(overall_scale, stroke_width, glow_width, scale)
    shape               = primitive_shape(p[1])
    uv_offset_width     = Vec4f0(0,0,1,1)     => GLBuffer
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
    boundingbox         = const_lift(GLBoundingBox, position)
    preferred_camera    = :orthographic_pixel
    shader              = GLVisualizeShader("util.vert", "sprites.geom", "sprites.vert", "distance_shape.frag")
    gl_primitive        = GL_POINTS
end
