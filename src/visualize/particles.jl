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
    data[:offset] = Vec2f0(0)
    _default((geometry, const_lift(x->Point2f0[minimum(x)], geometry)), s, data)
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
        color_norm = const_lift(extrema2f0, rotation_s)
        ranges = ntuple(i->linspace(0f0, 1f0, size(rotation_v, i)), N)
    end
    grid = Grid(rotation_v, ranges)

    if N == 1
        scalevec = Vec2f0(step(grid.dims[1]), 1)
    elseif N == 2
        scalevec = Vec2f0(step(grid.dims[1]), step(grid.dims[2]))
    else
        scalevec = Vec3f0(ntuple(i->step(grid.dims[i]), 3)).*Vec3f0(0.4,0.4, 1/value(color_norm)[2]*4)
    end
    if P <: Char # we need to preserve proportion of the glyph
        scalevec = Vec2f0(glyph_scale!(primitive, scalevec[1]))
        @gen_defaults! data begin # for chars we need to make sure they're centered
            offset = -scalevec/2f0
        end
    end
    @gen_defaults! data begin
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
        scale = nothing
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
        p::Tuple{TOrSignal{Pr}, VecTypes{P}}, s::Style, data::Dict
    )
    meshparticle(p, s, data)
end

function _default{Pr <: Primitives3D, G <: Tuple}(
        p::Tuple{TOrSignal{Pr}, G}, s::Style, data::Dict
    )
    @gen_defaults! data begin
        primitive = p[1]
        position         = nothing => TextureBuffer
        position_x       = p[2][1] => TextureBuffer
        position_y       = p[2][2] => TextureBuffer
        position_z       = length(p[2]) > 2 ? p[2][3] : 0f0 => TextureBuffer
        instances        = const_lift(length, position_x)
    end
    meshparticle(p, s, data)
end

function _default{Pr <: Primitives3D, G <: Grid}(
        p::Tuple{TOrSignal{Pr}, G}, s::Style, data::Dict
    )
    meshparticle(p, s, data)
end

# make conversion of mesh signals work. TODO move to GeometryTypes?
function Base.convert{T<:GeometryTypes.HomogenousMesh}(::Type{T}, mesh::Signal)
    map(T, mesh)
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
        rotation, value(primitive)
    )
    @gen_defaults! data begin
        color_map  = nothing => Texture
        color_norm = nothing
        intensity  = nothing
        color      = if color_map == nothing
            default(RGBA{Float32}, s)
        else
             nothing
        end => TextureBuffer

        instances   = const_lift(length, position)
        boundingbox = const_lift(GLBoundingBox, inst)
        shading    = true
        shader      = GLVisualizeShader(
            "util.vert", "particles.vert", "fragment_output.frag", "standard.frag",
            view = Dict(
                "position_calc" => position_calc(position, position_x, position_y, position_z, TextureBuffer),
                "light_calc" => light_calc(shading)
            )
        )
    end
    if position != nothing
        data[:intensity] = intensity_convert(intensity, position)
        data[:len] = const_lift(length, position)
    else
        data[:intensity] = intensity_convert(intensity, position_x)
        data[:len] = const_lift(length, position_x)
    end
    data
end

"""
This is the most primitive particle system, which uses simple points as primitives.
This is supposed to be the fastest way of displaying particles!
"""
_default{T <: Point}(position::VecTypes{T}, s::style"speed", data::Dict) = @gen_defaults! data begin
    vertex       = position => GLBuffer
    color_map    = nothing  => Vec2f0
    color        = (color_map == nothing ? default(RGBA{Float32}, s) : nothing) => GLBuffer

    color_norm   = nothing  => Vec2f0
    intensity = nothing  => GLBuffer
    point_size   = 2f0
    #boundingbox = ParticleBoundingBox(position, Vec3f0(1), SimpleRectangle(-point_size/2,-point_size/2, point_size, point_size))
    prerender    = ()->glPointSize(point_size)
    shader       = GLVisualizeShader("fragment_output.frag", "dots.vert", "dots.frag")
    gl_primitive = GL_POINTS
end

"""
returns the Shape for the distancefield algorithm
"""
primitive_shape(::Char) = DISTANCEFIELD
primitive_shape{X}(x::X) = primitive_shape(X)
primitive_shape{T<:Circle}(::Type{T}) = CIRCLE
primitive_shape{T<:SimpleRectangle}(::Type{T}) = RECTANGLE
primitive_shape{T<:HyperRectangle{2}}(::Type{T}) = RECTANGLE
primitive_shape(x::Shape) = x

"""
Extracts the scale from a primitive.
"""
primitive_scale(prim::GeometryPrimitive) = Vec2f0(widths(prim))
primitive_scale(::Union{Shape, Char}) = Vec2f0(40)
primitive_scale(c) = Vec2f0(0.1)

"""
Extracts the offset from a primitive.
"""
#primitive_offset(prim::GeometryPrimitive) = Vec2f0(minimum(prim))

primitive_offset(x, scale::Void) = Vec2f0(0) # default offset
primitive_offset(x, scale) = const_lift(./, scale, -2f0)  # default offset


"""
Extracts the uv offset and width from a primitive.
"""
primitive_uv_offset_width(c::Char) = glyph_uv_width!(c)
primitive_uv_offset_width(x) = Vec4f0(0,0,1,1)

"""
Gets the texture atlas if primitive is a char.
"""
primitive_distancefield(x) = nothing
primitive_distancefield(::Char) = get_texture_atlas().images




if isdefined(Images, :ImageAxes)
    """
    Particles with an image as primitive
    """
    function _default{Pr <: HasAxesArray, P <: Point}(
        p::Tuple{TOrSignal{Pr}, VecTypes{P}}, s::Style, data::Dict
    )
        _default((const_lift(img -> gl_convert(img), p[1]), p[2]), s, data)
    end
else
    include_string("""
    function _default{Pr <: Images.Image, P <: Point}(
            p::Tuple{TOrSignal{Pr}, VecTypes{P}}, s::Style, data::Dict
        )
        _default((const_lift(img -> img.data, p[1]), p[2]), s, data)
    end
    """)
end
function _default{C <: Colorant, P <: Point}(
        p::Tuple{TOrSignal{Matrix{C}}, VecTypes{P}}, s::Style, data::Dict
    )
    data[:image] = p[1] # we don't want this to be overwritten by user
    @gen_defaults! data begin
        scale = map(Vec2f0, const_lift(size, p[1]))
        shape = RECTANGLE
        offset = Vec2f0(0)
    end
    sprites(p, s, data)
end
function _default{C <: AbstractFloat, P <: Point}(
        p::Tuple{TOrSignal{Matrix{C}}, VecTypes{P}}, s::Style, data::Dict
    )
    data[:distancefield] = p[1] # we don't want this to be overwritten by user
    @gen_defaults! data begin
        scale = map(Vec2f0, const_lift(size, p[1]))
        shape = RECTANGLE
        offset = Vec2f0(0)
    end
    sprites(p, s, data)
end

function _default{C <: Colorant, P <: Point}(
        p::Tuple{Vector{Matrix{C}}, VecTypes{P}}, s::Style, data::Dict
    )
    images = p[1]
    isempty(images) && error("Can not display empty vector of images as primitive")
    images = sort(images, by=size)
    sizes = map(size, images)
    scale = Vec2f0(first(sizes))
    if !all(x-> x == sizes[1], sizes) # if differently sized
        # create texture atlas
        maxdims = sum(map(Vec{2, Int}, sizes))
        rectangles = map(x->SimpleRectangle(0,0,x...), sizes)
        rpack = RectanglePacker(SimpleRectangle(0, 0, maxdims...))
        uv_coordinates = [push!(rpack, rect).area for rect in rectangles]
        max_xy = mapreduce(maximum, max, uv_coordinates)
        texture_atlas = Texture(C, tuple(max_xy...))
        for (area, img) in zip(uv_coordinates, images)
            texture_atlas[area] = img #transfer to texture atlas
        end
        scale = map(Vec2f0, map(widths, uv_coordinates))
        data[:uv_offset_width] = map(uv_coordinates) do uv
            mini = minimum(uv) ./ max_xy
            maxi = maximum(uv) ./ max_xy
            Vec4f0(mini..., maxi...)
        end
        images = texture_atlas
    end
    data[:image] = images # we don't want this to be overwritten by user
    @gen_defaults! data begin
        scale = scale
        shape = RECTANGLE
        offset = Vec2f0(0)
    end
    sprites(p, s, data)
end

# There is currently no way to get the two following two signatures
# under one function, which is why we delegate to sprites
_default{Primitive<:Sprites, P<:Point}(p::Tuple{Primitive, VecTypes{P}}, s::Style, data::Dict) =
    sprites(p,s,data)

_default{Primitive<:Sprites, G<:Grid}(p::Tuple{Primitive, G}, s::Style, data::Dict) =
    sprites(p,s,data)

function _default{Pr <: Sprites, G <: Tuple}(
            p::Tuple{Pr, G}, s::Style, data::Dict
        )
        @gen_defaults! data begin
            shape      = primitive_shape(p[1])
            position   = nothing => GLBuffer
            position_x = p[2][1] => GLBuffer
            position_y = p[2][2] => GLBuffer
            position_z = length(p[2]) > 2 ? p[2][3] : 0f0 => GLBuffer
        end
        sprites(p, s, data)
    end

"""
Main assemble functions for sprite particles.
Sprites are anything like distance fields, images and simple geometries
"""
function sprites(p, s, data)
    @gen_defaults! data begin
        shape       = primitive_shape(p[1])
        position    = p[2]    => GLBuffer
        position_x  = nothing => GLBuffer
        position_y  = nothing => GLBuffer
        position_z  = nothing => GLBuffer

        scale       = primitive_scale(p[1])  => GLBuffer
        scale_x     = nothing                => GLBuffer
        scale_y     = nothing                => GLBuffer
        scale_z     = nothing                => GLBuffer

        rotation    = Vec3f0(0,0,1)          => GLBuffer
        image       = nothing => Texture
    end
    # TODO don't make this dependant on some shady type dispatch
    if isa(p[1], Char) && !isa(scale, Vec) # correct dimensions
        scale = Vec2f0(glyph_scale!(p[1], scale))
        data[:scale] = scale
    end
    inst = _Instances(
        position, position_x, position_y, position_z,
        scale, scale_x, scale_y, scale_z,
        rotation, SimpleRectangle{Float32}(0,0,1,1)
    )
    @gen_defaults! data begin
        offset          = primitive_offset(p[1], scale) => GLBuffer
        intensity       = nothing => GLBuffer
        color_map       = nothing => Texture
        color_norm      = nothing
        color           = (color_map == nothing ? default(RGBA, s) : nothing) => GLBuffer

        glow_color      = RGBA{Float32}(0,0,0,0) => GLBuffer
        stroke_color    = RGBA{Float32}(0,0,0,0) => GLBuffer
        stroke_width    = 0f0
        glow_width      = 0f0
        uv_offset_width = primitive_uv_offset_width(p[1]) => GLBuffer

        distancefield   = primitive_distancefield(p[1]) => Texture
        indices         = const_lift(length, p[2]) => to_indices
        boundingbox     = const_lift(GLBoundingBox, inst)
        # rotation and billboard don't go along
        billboard        = rotation == Vec3f0(0,0,1) => "if `billboard` == true, particles will always face camera"
        preferred_camera = :orthographic_pixel
        fxaa             = false
        shader           = GLVisualizeShader(
            "fragment_output.frag", "util.vert", "sprites.geom",
            "sprites.vert", "distance_shape.frag",
            view = Dict("position_calc"=>position_calc(position, position_x, position_y, position_z, GLBuffer))
        )
        gl_primitive = GL_POINTS
    end
    # Exception for intensity, to make it possible to handle intensity with a
    # different length compared to position. Intensities will be interpolated in that case
    if position != nothing
        data[:intensity] = intensity_convert(intensity, position)
        data[:len] = const_lift(length, position)
    else
        data[:intensity] = intensity_convert(intensity, position_x)
        data[:len] = const_lift(length, position_x)
    end
    data
end


"""
Transforms text into a particle system of sprites, by inferring the
texture coordinates in the texture atlas, widths and positions of the characters.
"""
function _default{S <: AbstractString}(main::TOrSignal{S}, s::Style, data::Dict)
    @gen_defaults! data begin
        relative_scale  = 4mm #
        start_position  = Point2f0(0)
        atlas           = get_texture_atlas()
        distancefield   = atlas.images
        stroke_width    = 0f0
        glow_width      = 0f0
        font            = defaultfont()
        scale_primitive = true
        position        = const_lift(calc_position, main, start_position, relative_scale, font, atlas)
        offset          = const_lift(calc_offset, main, relative_scale, font, atlas)
        prerender       = () -> begin
            glDisable(GL_DEPTH_TEST)
            glDepthMask(GL_TRUE)
            glDisable(GL_CULL_FACE)
            enabletransparency()
        end
        uv_offset_width = const_lift(main) do str
            Vec4f0[glyph_uv_width!(atlas, c, font) for c = str]
        end
        scale = const_lift(main, relative_scale) do str, s
            Vec2f0[glyph_scale!(atlas, c, font, s)  for c = str]
        end
    end

    _default((DISTANCEFIELD, position), s, data)
end
