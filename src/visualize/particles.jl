typealias Primitives{N} Union{GeometryPrimitive{N}, AbstractMesh}
typealias Primitives3D  Primitives{3}
typealias Sprites Union{GeometryPrimitive{2}, Shape, Char}

typealias ExtPrimitives Union{Primitives, Sprites}

_default{T<:AbstractFloat}(main::VecTypes{T}, s::Style, data::Dict) = _default((centered(HyperRectangle{2, Float32}), main), s, data)
_default{T<:AbstractFloat}(main::MatTypes{T}, s::Style, data::Dict) = _default((AABB(Vec3f0(-0.5,-0.5,0), Vec3f0(1.0)), main), s, data)
_default{N, T}(main::VecTypes{Point{N, T}}, s::Style, data::Dict)   = _default((centered(HyperRectangle{N, Float32}), main), s, data)


_default{T<:Vec}(main::ArrayTypes{T, 3}, s::Style, data::Dict) = _default((Pyramid(Point3f0(0,0,-0.5), 1f0, 0.2f0), main), s, data)
_default{T<:Vec}(main::ArrayTypes{T, 2}, s::Style, data::Dict) = _default(('⬆', main), s, data)

function _default{P<:Primitives3D, N, T<:Vec}(main::Tuple{P, ArrayTypes{T, N}}, s::Style, data::Dict)
    data[:rotation] = const_lift(vec, main[2])
    get!(data, :color_norm) do
        const_lift(extrema2f0, main[2])
    end
    get!(data, :color, Texture(default(Vector{RGBA})))
    _default((main[1], Grid(main[2])), s, data)
end
function _default{P<:Sprites, N, T<:Vec}(main::Tuple{P, ArrayTypes{T, N}}, s::Style, data::Dict)
    @gen_defaults! data begin
        rotation   = const_lift(vec, main[2])
        color_norm = const_lift(extrema2f0, main[2])
        color      = Texture(default(Vector{RGBA}))
        xyrange    = ntuple(x->(0,1), N)
    end
    _default((main[1], Grid(value(main[2]), xyrange)), s, data)
end

function _default{N, P<:Primitives, T<:AbstractFloat}(main::Tuple{P, ArrayTypes{T,N}}, s::Style, data::Dict)
    grid = Grid(value(main[2]))
    @gen_defaults! data begin
        scale            = nothing
        scale_x::Float32 = step(grid.dims[1])
        scale_y::Float32 = N==1 ? 1f0 : step(grid.dims[2])
        scale_z = const_lift(vec, main[2]) => TextureBuffer
    end
    _default((main[1], grid), s, data)
end
function _default{N, P<:Sprites, T<:AbstractFloat}(main::Tuple{P, ArrayTypes{T,N}}, s::Style, data::Dict)
    grid = Grid(value(main[2]))
    @gen_defaults! data begin
        position_z = const_lift(vec, main[2]) => GLBuffer
        scale = Vec3f0(step(grid.dims[1]), N>=2 ? step(grid.dims[2]) : 1f0, 1)
    end
    _default((main[1], grid), s, data)
end
function _default{P<:Sprites, T<:AbstractFloat}(main::Tuple{P, VecTypes{T}}, s::Style, data::Dict)
    @gen_defaults! data begin
        xyrange    = ((0,500),)
    end
    grid = Grid(value(main[2]), xyrange)
    @gen_defaults! data begin
        scale            = nothing
        scale_x::Float32 = step(grid.dims[1])
        scale_y          = main[2] => GLBuffer
        scale_z::Float32 = 1f0
    end
    _default((main[1], grid), s, data)
end

to_ram(x) = x
to_ram(x::GPUArray) = gpu_data(x)

function _Instances(position,px,py,pz, scale,sx,sy,sz, rotation, primitive)
    args = (position,px,py,pz, scale,sx,sy,sz, rotation, primitive)
    args = map(to_ram, args)
    p = const_lift(ArrayOrStructOfArray, Point3f0, args[1:4]...)
    s = const_lift(ArrayOrStructOfArray, Vec3f0, args[5:8]...)
    r = const_lift(ArrayOrStructOfArray, Vec3f0, args[9])
    const_lift(Instances, args[10], p, s, r)
end
function _Instances(position, scale, rotation, primitive)
    p = const_lift(ArrayOrStructOfArray, Point3f0, position)
    s = const_lift(ArrayOrStructOfArray, Vec3f0, scale)
    r = const_lift(ArrayOrStructOfArray, Vec3f0, rotation)
    const_lift(Instances, primitive, p, s, r)
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
        position         = p[2] => TextureBuffer
        position_x       = nothing => TextureBuffer
        position_y       = nothing => TextureBuffer
        position_z       = nothing => TextureBuffer

        scale            = Vec3f0(1) => TextureBuffer
        scale_x          = nothing => TextureBuffer
        scale_y          = nothing => TextureBuffer
        scale_z          = nothing => TextureBuffer

        rotation         = Vec3f0(0,0,1) => TextureBuffer
    end
    inst = _Instances(
        position, position_x, position_y, position_z,
        scale, scale_x, scale_y, scale_z,
        rotation, primitive
    )
    @gen_defaults! data begin
        color            = default(RGBA{Float32}, s) => TextureBuffer
        intensity        = nothing    => TextureBuffer
        color_norm       = nothing
        instances        = const_lift(length, position)
        boundingbox      = const_lift(GLBoundingBox, inst)
        shader           = GLVisualizeShader(
            "util.vert", "particles.vert", "standard.frag",
            view=Dict("position_calc"=>position_calc(position, position_x, position_y, position_z, TextureBuffer))
        )
    end
end

_default{T <: Point}(position::VecTypes{T}, s::style"speed", data::Dict) = @gen_defaults! data begin
    vertex       = position                  => GLBuffer
    color        = default(RGBA{Float32}, s) => GLBuffer
    intensity    = nothing                   => GLBuffer
    color_norm   = nothing                   => Vec2f0
    point_size   = 2f0
    #boundingbox  = ParticleBoundingBox(position, Vec3f0(1), SimpleRectangle(-point_size/2,-point_size/2, point_size, point_size))
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
primitive_scale(c::Char)  = Vec(glyph_scale!(c))

primitive_offset(c::Circle) = Vec2f0(c.center)-c.r
primitive_offset(r::HyperRectangle) = Vec2f0(minimum(r))
primitive_offset(r::SimpleRectangle) = Vec2f0(r.x, r.y)
primitive_offset(r::Shape) = Vec2f0(0)
primitive_offset(c::Char)  = Vec2f0(0)


primitive_uv_offset_width(c::Char) = glyph_uv_width!(c)
primitive_uv_offset_width(x)       = Vec4f0(0,0,1,1)

primitive_distancefield(x) = nothing
primitive_distancefield(::Char) = get_texture_atlas().images

_default{Primitive<:Union{GeometryPrimitive{2}, Shape, Char}, P<:Point}(p::Tuple{Primitive, VecTypes{P}}, s::Style, data::Dict) =
    sprites(p,s,data)

_default{Primitive<:Union{GeometryPrimitive{2}, Shape, Char}, G<:Grid}(p::Tuple{Primitive, G}, s::Style, data::Dict) =
    sprites(p,s,data)

function sprites(p, s, data)
    @gen_defaults! data begin
        shape               = primitive_shape(p[1])
        position            = p[2]    => GLBuffer
        position_x          = nothing => GLBuffer
        position_y          = nothing => GLBuffer
        position_z          = nothing => GLBuffer

        scale               = primitive_scale(p[1])  => GLBuffer
        scale_x             = nothing                => GLBuffer
        scale_y             = nothing                => GLBuffer
        scale_z             = nothing                => GLBuffer

        rotation            = Vec3f0(0,0,1)          => GLBuffer
        offset              = primitive_offset(p[1]) => GLBuffer

    end
    inst = _Instances(
        position, position_x, position_y, position_z,
        scale, scale_x, scale_y, scale_z,
        rotation, SimpleRectangle{Float32}(0,0,1,1)
    )
    @gen_defaults! data begin
        color               = default(RGBA, s)       => GLBuffer
        intensity           = nothing                => GLBuffer
        color_norm          = nothing
        stroke_color        = default(RGBA, s, 2)    => GLBuffer
        glow_color          = default(RGBA, s, 3)    => GLBuffer

        stroke_width        = 0f0
        glow_width          = 0f0
        uv_offset_width     = primitive_uv_offset_width(p[1]) => GLBuffer

        image               = nothing => Texture
        distancefield       = primitive_distancefield(p[1]) => Texture
        indices             = const_lift(length, p[2]) => to_indices
        boundingbox         = const_lift(GLBoundingBox, inst)
        preferred_camera    = :orthographic_pixel
        shader              = GLVisualizeShader(
            "util.vert", "sprites.geom",
            "sprites.vert", "distance_shape.frag",
            view=Dict("position_calc"=>position_calc(position, position_x, position_y, position_z, GLBuffer))
        )
        gl_primitive        = GL_POINTS
    end
end



function _default{S<:AbstractString}(main::TOrSignal{S}, s::Style, data::Dict)

    @gen_defaults! data begin
        scale          = Vec2f0(1)   => GLBuffer
        start_position = Point2f0(0) => GLBuffer
        atlas          = get_texture_atlas()
        distancefield  = atlas.images
        stroke_width   = 0f0
        glow_width     = 0f0
        font           = DEFAULT_FONT_FACE
    end

    t_uv     = const_lift(main) do str
        Vec4f0[glyph_uv_width!(atlas, c, font) for c=str]
    end
    t_scale  = const_lift(main) do str
        Vec2f0[glyph_scale!(atlas, c, font).*scale for c=str]
    end
    data[:scale]           = t_scale
    data[:uv_offset_width] = t_uv
    position_offset = const_lift(calc_position, main, start_position, scale, font, atlas)
    data[:offset] = map(last, position_offset)
    _default((DISTANCEFIELD, map(first, position_offset)), s, data)
end
