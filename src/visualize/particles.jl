#=
A lot of visualization forms in GLVisualize are realised in the form of instanced
particles. This is because they can be handled very efficiently by OpenGL.
There are quite a few different ways to feed instances with different attributes.
The main constructor for particles is a tuple of (Primitive, Position), whereas
position can come in all forms and shapes. You can leave away the primitive.
In that case, GLVisualize will fill in some default that is anticipated to make
the most sense for the datatype.
=#

#3D primitives
typealias Primitives3D  Union{AbstractGeometry{3}, AbstractMesh}
#2D primitives AKA sprites, since they are shapes mapped onto a 2D rectangle
typealias Sprites Union{AbstractGeometry{2}, Shape, Char, Type}
typealias AllPrimitives Union{AbstractGeometry, Shape, Char}


"""
We plot simple Geometric primitives as particles with length one.
At some point, this should all be appended to the same particle system to increase
performance.
"""
function _default{G<:GeometryPrimitive{2}}(
        geometry::TOrSignal{G}, s::Style, data::Dict
    )
    _default((geometry, zeros(Point{2, Float32}, 1)), s, data)
end

"""
Vectors of floats are treated as barplots, so they get a HyperRectangle as
default primitive.
"""
function _default{T<:AbstractFloat}(main::VecTypes{T}, s::Style, data::Dict)
    _default((centered(HyperRectangle{2, Float32}), main), s, data)
end
"""
Matrices of floats are represented as 3D barplots with cubes as primitive
"""
function _default{T<:AbstractFloat}(main::MatTypes{T}, s::Style, data::Dict)
    _default((AABB(Vec3f0(-0.5,-0.5,0), Vec3f0(1.0)), main), s, data)
end
"""
Vectors of n-dimensional points get ndimensional rectangles as default
primitives. (Particles)
"""
function _default{N, T}(main::VecTypes{Point{N, T}}, s::Style, data::Dict)
    @gen_defaults! data begin
        scale = N == 2 ? Vec2f0(30) : Vec3f0(0.03) # for 2D points we assume they're in pixels
    end
    _default((centered(HyperRectangle{N, Float32}), main), s, data)
end

"""
3D matrices of vectors are 3D vector field with a pyramid (arrow) like default
primitive.
"""
function _default{T<:Vec}(main::ArrayTypes{T, 3}, s::Style, data::Dict)
    _default((Pyramid(Point3f0(0,0,-0.5), 1f0, 0.2f0), main), s, data)
end
"""
2D matrices of vectors are 2D vector field with a an unicode arrow as the default
primitive.
"""
function _default{T<:Vec}(main::ArrayTypes{T, 2}, s::Style, data::Dict)
    _default(('⬆', main), s, data)
end

"""
Vectors with `Vec` as element type are treated as vectors of rotations.
The position is assumed to be implicitely on the grid the vector defines (1D,2D,3D grid)
"""
function _default{P<:AllPrimitives, T<:Vec, N}(
        main::Tuple{P, ArrayTypes{T, N}}, s::Style, data::Dict
    )
    primitive, rotation_s = main
    rotation_v = value(rotation_s)
    @gen_defaults! data begin
        ranges = ntuple(i->linspace(0f0, 1f0, size(rotation_v, i)), N)
    end
    grid = Grid(rotation_v, ranges)

    if N == 1
        scalevec = Vec2f0(step(grid.dims[1]), 1)
    elseif N == 2
        scalevec = Vec2f0(step(grid.dims[1]), step(grid.dims[2]))
    else
        scalevec = Vec3f0(ntuple(i->step(grid.dims[i]), 3))
    end
    if P <: Char # we need to preserve proportion of the glyph
        glyphscale = primitive_scale(primitive)
        glyphscale /= max(glyphscale...)
        scalevec = Vec2f0(scalevec).*glyphscale
        @gen_defaults! data begin # for chars we need to make sure they're centered
            offset = -scalevec/2f0
        end
    end
    @gen_defaults! data begin
        color_norm = const_lift(extrema2f0, rotation_s)
        rotation   = const_lift(vec, rotation_s)
        color_map  = default(Vector{RGBA})
        scale      = scalevec
        color      = nothing
    end
    _default((primitive, grid), s, data)
end

"""
arrays of floats with any geometry primitive, will be spaced out on a grid defined
by `ranges` and will use the floating points as the
height for the primitives (`scale_z`)
"""
function _default{P<:AbstractGeometry, T<:AbstractFloat, N}(
        main::Tuple{P, ArrayTypes{T,N}}, s::Style, data::Dict
    )
    primitive, heightfield_s = main
    heightfield = value(heightfield_s)
    @gen_defaults! data begin
        ranges = ntuple(i->linspace(0f0, 1f0, size(heightfield, i)), N)
    end
    grid = Grid(heightfield, ranges)
    @gen_defaults! data begin
        scale            = nothing
        scale_x::Float32 = step(grid.dims[1])
        scale_y::Float32 = N==1 ? 1f0 : step(grid.dims[2])
        scale_z = const_lift(vec, heightfield_s)
        color = nothing
        color_map  = color == nothing ? default(Vector{RGBA}) : nothing
        color_norm = color == nothing ? const_lift(extrema2f0, heightfield_s) : nothing
    end
    _default((primitive, grid), s, data)
end

"""
arrays of floats with the sprite primitive type (2D geometry + picture like),
will be spaced out on a grid defined
by `ranges` and will use the floating points as the
z position for the primitives.
"""
function _default{P<:Sprites, T<:AbstractFloat, N}(
        main::Tuple{P, ArrayTypes{T,N}}, s::Style, data::Dict
    )
    primitive, heightfield_s = main
    heightfield = value(heightfield_s)
    @gen_defaults! data begin
        ranges = ntuple(i->linspace(0f0, 1f0, size(heightfield, i)), N)
    end
    grid = Grid(heightfield, ranges)
    @gen_defaults! data begin
        position_z = const_lift(vec, heightfield_s)
        scale      = Vec2f0(step(grid.dims[1]), N>=2 ? step(grid.dims[2]) : 1f0)
        color_map  = default(Vector{RGBA})
        color      = nothing
        color_norm = const_lift(extrema2f0, heightfield_s)
    end
    _default((primitive, grid), s, data)
end
"""
Sprites primitives with a vector of floats are treated as something barplot like
"""
function _default{P<:Sprites, T<:AbstractFloat}(
        main::Tuple{P, VecTypes{T}}, s::Style, data::Dict
    )
    primitive, heightfield_s = main
    heightfield = value(heightfield_s)
    @gen_defaults! data begin
        ranges = linspace(0f0, 1f0, length(heightfield))
    end
    grid = Grid(heightfield, ranges)
    @gen_defaults! data begin
        scale            = nothing
        scale_x::Float32 = step(grid.dims[1])
        scale_y          = heightfield_s
        scale_z::Float32 = 1f0
    end
    _default((primitive, grid), s, data)
end



# There is currently no way to get the two following two signatures
# under one function, which is why we delegate to meshparticle
function _default{Pr <: Primitives3D, P <: Point}(
        p::Tuple{Pr, VecTypes{P}}, s::Style, data::Dict
    )
    meshparticle(p, s, data)
end

function _default{Pr <: Primitives3D, G <: Grid}(
        p::Tuple{Pr, G}, s::Style, data::Dict
    )
    meshparticle(p, s, data)
end
"""
This is the main function to assemble particles with a GLNormalMesh as a primitive
"""
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
        color_map        = nothing => Texture
        color_norm       = nothing
        intensity        = nothing => TextureBuffer
        color            = if color_map == nothing
            default(RGBA{Float32}, s)
        else
             nothing
        end => TextureBuffer

        instances   = const_lift(length, position)
        boundingbox = const_lift(GLBoundingBox, inst)
        shader      = GLVisualizeShader(
            "util.vert", "particles.vert", "standard.frag",
            view=Dict("position_calc"=>position_calc(position, position_x, position_y, position_z, TextureBuffer))
        )
    end
end

"""
This is the most primitive particle system, which uses simple points as primitives.
This is supposed to be very fast!
"""
_default{T <: Point}(position::VecTypes{T}, s::style"speed", data::Dict) = @gen_defaults! data begin
    vertex       = position                  => GLBuffer
    color_map    = nothing                   => Vec2f0
    color        = (color_map == nothing ? default(RGBA{Float32}, s) : nothing) => GLBuffer

    color_norm   = nothing                   => Vec2f0
    intensity    = nothing                   => GLBuffer
    point_size   = 2f0
    #boundingbox  = ParticleBoundingBox(position, Vec3f0(1), SimpleRectangle(-point_size/2,-point_size/2, point_size, point_size))
    prerender    = (
        (glPointSize,   point_size),
    )
    shader       = GLVisualizeShader("dots.vert", "dots.frag")
    gl_primitive = GL_POINTS
end

primitive_shape(::Char) = DISTANCEFIELD
primitive_shape{X}(x::X) = primitive_shape(X)
primitive_shape{T<:Circle}(::Type{T}) = CIRCLE
primitive_shape{T<:SimpleRectangle}(::Type{T}) = RECTANGLE
primitive_shape{T<:HyperRectangle{2}}(::Type{T}) = RECTANGLE
primitive_shape(x::Shape) = x

primitive_scale(prim::GeometryPrimitive) = Vec2f0(widths(prim))
primitive_scale(::Shape) = Vec2f0(40)
primitive_scale(c::Char) = Vec(glyph_scale!(c))

primitive_offset(x) = Vec2f0(0) # default offset
primitive_offset(prim::GeometryPrimitive) = -Vec2f0(widths(prim)) / 2f0
primitive_offset(x::Char) = -Vec(glyph_scale!(x)) / 2f0


primitive_uv_offset_width(c::Char) = glyph_uv_width!(c)
primitive_uv_offset_width(x) = Vec4f0(0,0,1,1)

primitive_distancefield(x) = nothing
primitive_distancefield(::Char) = get_texture_atlas().images


# There is currently no way to get the two following two signatures
# under one function, which is why we delegate to sprites
_default{Primitive<:Sprites, P<:Point}(p::Tuple{Primitive, VecTypes{P}}, s::Style, data::Dict) =
    sprites(p,s,data)

_default{Primitive<:Sprites, G<:Grid}(p::Tuple{Primitive, G}, s::Style, data::Dict) =
    sprites(p,s,data)


"""
Main assemble functions for sprite particles.
Sprites are anything like distance fields, images and simple geometries
"""
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
        intensity           = nothing => GLBuffer
        color_map           = nothing => Texture
        color_norm          = nothing
        color               = (color_map == nothing ? default(RGBA, s) : nothing) => GLBuffer

        glow_color          = RGBA{Float32}(0,0,0,0) => GLBuffer
        stroke_color        = RGBA{Float32}(0,0,0,0) => GLBuffer

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


"""
Transforms text into a particle system of sprites, by inferring the
texture coordinates in the texture atlas, widths and positions of the characters.
"""
function _default{S<:AbstractString}(main::TOrSignal{S}, s::Style, data::Dict)

    @gen_defaults! data begin
        relative_scale = Vec2f0(1)
        start_position = Point2f0(0)
        atlas          = get_texture_atlas()
        distancefield  = atlas.images
        stroke_width   = 0f0
        glow_width     = 0f0
        font           = DEFAULT_FONT_FACE
        position        = const_lift(calc_position, main, start_position, relative_scale, font, atlas)
        offset          = const_lift(calc_offset, main, relative_scale, font, atlas)
        uv_offset_width = const_lift(main) do str
            Vec4f0[glyph_uv_width!(atlas, c, font) for c=str]
        end
        scale           = const_lift(main, relative_scale) do str, s
            Vec2f0[glyph_scale!(atlas, c, font).*s for c=str]
        end
    end

    _default((DISTANCEFIELD, position), s, data)
end
