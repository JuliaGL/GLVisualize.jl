typealias Primitives{N} Union{GeometryPrimitive{N}, AbstractMesh}
typealias Primitives3D  Primitives{3}
typealias Sprites Union{GeometryPrimitive{2}, Shape, Char}

typealias ExtPrimitives Union{Primitives, Sprites}

_default{T<:AbstractFloat}(main::VecTypes{T}, s::Style, data::Dict) = _default((centered(HyperRectangle{2, Float32}), main), s, data)
_default{T<:AbstractFloat}(main::MatTypes{T}, s::Style, data::Dict) = _default((HyperCube(Vec3f0(-0.5,-0.5,0),Vec3f0(1)), main), s, data)
_default{N, T}(main::VecTypes{Point{N, T}}, s::Style, data::Dict)   = _default((centered(HyperRectangle{N, Float32}), main), s, data)

function create_minmax{T<:Vec,N}(x::Array{T,N})
    _norm = map(norm, x)
    Vec2f0(minimum(_norm), maximum(_norm))
end
const ARROW = '\U2B06'

_default{T<:Vec}(main::ArrayTypes{T, 3}, s::Style, data::Dict) = _default((Pyramid(Point3f0(0,0,-0.5), 1f0, 0.2f0), main), s, data)
_default{T<:Vec}(main::ArrayTypes{T, 2}, s::Style, data::Dict) = _default((ARROW, main), s, data)

function _default{P<:Primitives3D, N, T<:Vec}(main::Tuple{P, ArrayTypes{T, N}}, s::Style, data::Dict)
    data[:rotation] = const_lift(vec, main[2])
    get!(data, :color_norm) do
        const_lift(create_minmax, main[2])
    end
    get!(data, :color, Texture(default(Vector{RGBA})))
    _default((main[1], Grid(main[2])), s, data)
end
function _default{P<:Sprites, N, T<:Vec}(main::Tuple{P, ArrayTypes{T, N}}, s::Style, data::Dict)
    @gen_defaults! data begin
        rotation   = const_lift(vec, main[2])
        color_norm = const_lift(create_minmax, main[2])
        color      = Texture(default(Vector{RGBA}))
        xyrange    = ((0,1),(0,1))
    end
    _default((main[1], Grid(value(main[2]), xyrange)), s, data)
end

function _default{N, P<:Primitives, T<:AbstractFloat}(main::Tuple{P, ArrayTypes{T,N}}, s::Style, data::Dict)
    grid = Grid(value(main[2]))
    @gen_defaults! data begin
        scale_z = const_lift(vec, main[2]) => TextureBuffer
        scale_x::Float32 = step(grid.dims[1])
        scale_y::Float32 = N==1 ? 0.1f0 : step(grid.dims[2])
    end
    _default((main[1], grid), s, data)
end
function _default{N, P<:Sprites, T<:AbstractFloat}(main::Tuple{P, ArrayTypes{T,N}}, s::Style, data::Dict)
    grid = Grid(value(main[2]))
    @gen_defaults! data begin
        position_z = const_lift(vec, main[2]) => GLBuffer
        scale = Vec2f0(step(grid.dims[1]), N>=2 ? step(grid.dims[2]) : 1f0)
    end
    _default((main[1], grid), s, data)
end
function _default{P<:Sprites, T<:AbstractFloat}(main::Tuple{P, VecTypes{T}}, s::Style, data::Dict)
    @gen_defaults! data begin
        xyrange    = ((0,500),)
    end
    grid = Grid(value(main[2]), xyrange)
    @gen_defaults! data begin
        scale_x::Float32 = step(grid.dims[1])
        scale_y          = const_lift(vec, main[2]) => GLBuffer
        scale_z::Float32 = 1f0
    end
    _default((main[1], grid), s, data)
end


function ParticleBoundingBox(position,px,py,pz, scale,sx,sy,sz, primitive)
    position_it  = const_lift(PositionIterator, position, px, py, pz)
    scale_it     = const_lift(ScaleIterator, scale, sx, sy, sz)
    primitive_bb = const_lift(GLBoundingBox, primitive)
    const_lift(GLBoundingBox, position_it, scale_it, primitive_bb)
end
function ParticleBoundingBox(position, scale, primitive)
    position_it  = const_lift(PositionIterator, position, nothing, nothing, nothing)
    scale_it     = const_lift(ScaleIterator, scale, nothing, nothing, nothing)
    primitive_bb = const_lift(GLBoundingBox, primitive)
    const_lift(GLBoundingBox, position_it, scale_it, primitive_bb)
end

# There is currently no way to get the two following two signatures
# under one function, which is why we delegate to meshparticle
_default{Pr <: Primitives3D, P <: Point}(p::Tuple{Pr, VecTypes{P}}, s::Style, data::Dict) =
    meshparticle(p, s, data)

_default{Pr <: Primitives3D, G <: Grid}(p::Tuple{Pr, G}, s::Style, data::Dict) =
    meshparticle(p, s, data)

function meshparticle(p, s, data)
    @gen_defaults! data begin
        primitive::GLNormalMesh = p[1]
        color            = default(RGBA{Float32}, s) => TextureBuffer

        position         = p[2]       => TextureBuffer
        position_x       = nothing    => TextureBuffer
        position_y       = nothing    => TextureBuffer
        position_z       = nothing    => TextureBuffer

        scale            = Vec3f0(1)  => TextureBuffer
        scale_x          = nothing    => TextureBuffer
        scale_y          = nothing    => TextureBuffer
        scale_z          = nothing    => TextureBuffer

        rotation         = nothing    => TextureBuffer
        intensity        = nothing    => TextureBuffer
        color_norm       = nothing
        instances        = length(position)
        boundingbox      = ParticleBoundingBox(
            position, position_x, position_y, position_z,
            scale, scale_x, scale_y, scale_z,
            primitive
        )
        shader           = GLVisualizeShader("util.vert", "particles.vert", "standard.frag")
    end
end

_default{T <: Point}(position::VecTypes{T}, s::style"speed", data::Dict) = @gen_defaults! data begin
    vertex       = position                  => GLBuffer
    color        = default(RGBA{Float32}, s) => GLBuffer
    intensity    = nothing                   => GLBuffer
    color_norm   = nothing                   => Vec2f0
    point_size   = 2f0
    boundingbox  = ParticleBoundingBox(position, Vec3f0(1), SimpleRectangle(-point_size/2,-point_size/2, point_size, point_size))
    #prerender    = +((glPointSize, point_size),)
    shader       = GLVisualizeShader("dots.vert", "dots.frag")
    gl_primitive = GL_POINTS
end

primitive_shape(::Char)   = DISTANCEFIELD
primitive_shape(::Circle) = CIRCLE
primitive_shape(::SimpleRectangle) = RECTANGLE
primitive_shape{T}(::HyperRectangle{2,T}) = RECTANGLE
primitive_shape(x::Shape) = x

primitive_scale(c::Circle) = Vec(Vec2f0(c.center) + c.r)
primitive_scale(r::HyperRectangle) = Vec(maximum(r))
primitive_scale(r::SimpleRectangle) = Vec(maximum(r))
primitive_scale(r::Shape) = Vec2f0(40)
primitive_scale(c::Char)  = Vec(get_font_scale!(c))

primitive_offset(c::Circle) = Vec2f0(c.center)-c.r
primitive_offset(r::HyperRectangle) = Vec2f0(r.minimum)
primitive_offset(r::SimpleRectangle) = Vec2f0(r.x, r.y)
primitive_offset(r::Shape) = Vec2f0(0)
primitive_offset(c::Char)  = Vec2f0(0)


primitive_uv_offset_width(c::Char) = get_uv_offset_width!(c)
primitive_uv_offset_width(x)       = Vec4f0(0,0,1,1)

primitive_distancefield(x) = nothing
primitive_distancefield(::Char) = get_texture_atlas().images

_default{Primitive<:Union{GeometryPrimitive{2}, Shape, Char}, P<:Point}(p::Tuple{Primitive, VecTypes{P}}, s::Style, data::Dict) =
    sprites(p,s,data)

_default{Primitive<:Union{GeometryPrimitive{2}, Shape, Char}, G<:Grid}(p::Tuple{Primitive, G}, s::Style, data::Dict) =
    sprites(p,s,data)

sprites(p, s, data) = @gen_defaults! data begin
    shape               = primitive_shape(p[1])

    position            = p[2]    => GLBuffer
    position_x          = nothing => GLBuffer
    position_y          = nothing => GLBuffer
    position_z          = nothing => GLBuffer

    scale               = primitive_scale(p[1]) => GLBuffer
    scale_x             = nothing               => GLBuffer
    scale_y             = nothing               => GLBuffer
    scale_z             = nothing               => GLBuffer
    offset              = primitive_offset(p[1])=> GLBuffer
    rotation            = nothing             => GLBuffer
    color               = default(RGBA, s)    => GLBuffer
    intensity           = nothing             => GLBuffer
    color_norm          = nothing
    stroke_color        = default(RGBA, s, 2) => GLBuffer
    glow_color          = default(RGBA, s, 3) => GLBuffer

    stroke_width        = 0f0
    glow_width          = 0f0
    uv_offset_width     = primitive_uv_offset_width(p[1]) => GLBuffer

    image               = nothing => Texture
    distancefield       = primitive_distancefield(p[1]) => Texture
    transparent_picking = true

    boundingbox         = ParticleBoundingBox(
        position, position_x, position_y, position_z,
        scale, scale_x, scale_y, scale_z,
        SimpleRectangle{Float32}(0,0,1,1)
    )
    preferred_camera    = :orthographic_pixel
    shader              = GLVisualizeShader("util.vert", "sprites.geom", "sprites.vert", "distance_shape.frag")
    gl_primitive        = GL_POINTS
end


function _default{T<:AbstractString}(main::Signal{T}, s::Style, data::Dict)
    atlas       = get_texture_atlas()
    char_id     = preserve(map(process_for_gl, main))
    t_uv        = GLBuffer(Vec4f0[atlas.attributes[id+1] for id in char_id.value])
    t_scale     = GLBuffer(Vec2f0[atlas.scale[id+1] for id in char_id.value])
    position    = GLBuffer(map(Point2f0, calc_position(char_id.value)))
    vals        = map(char_id) do cid
        update!(t_uv    , Vec4f0[atlas.attributes[id+1] for id in cid])
        update!(t_scale , Vec2f0[atlas.scale[id+1] for id in cid])
        update!(position, map(Point2f0, calc_position(cid)))
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
