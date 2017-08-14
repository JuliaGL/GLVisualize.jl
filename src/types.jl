@enum Shape CIRCLE RECTANGLE ROUNDED_RECTANGLE DISTANCEFIELD TRIANGLE
@enum RaymarchAlgorithm IsoValue Absorption MaximumIntensityProjection
@enum CubeSides TOP BOTTOM FRONT BACK RIGHT LEFT

struct Grid{N, T <: Range}
    dims::NTuple{N, T}
end
Base.ndims{N,T}(::Grid{N,T}) = N

Grid(ranges::Range...) = Grid(ranges)
function Grid(a::Array{T, N}) where {N, T}
    s = Vec{N, Float32}(size(a))
    smax = maximum(s)
    s = s./smax
    Grid(ntuple(Val{N}) do i
        linspace(0, s[i], size(a, i))
    end)
end

Grid(a::AbstractArray, ranges...) = Grid(a, ranges)

"""
This constructor constructs a grid from ranges given as a tuple.
Due to the approach, the tuple `ranges` can consist of NTuple(2, T)
and all kind of range types. The constructor will make sure that all ranges match
the size of the dimension of the array `a`.
"""
function Grid(a::AbstractArray{T, N}, ranges::Tuple) where {T, N}
    length(ranges) =! N && throw(ArgumentError(
        "You need to supply a range for every dimension of the array. Given: $ranges
        given Array: $(typeof(a))"
    ))
    Grid(ntuple(Val{N}) do i
        linspace(first(ranges[i]), last(ranges[i]), size(a, i))
    end)
end

Base.length(p::Grid) = prod(size(p))
Base.size(p::Grid) = map(length, p.dims)
function Base.getindex(p::Grid{N,T}, i) where {N,T}
    inds = ind2sub(size(p), i)
    Point{N, eltype(T)}(ntuple(Val{N}) do i
        p.dims[i][inds[i]]
    end)
end

Base.start(g::Grid) = 1
Base.done(g::Grid, i) = i > length(g)
Base.next(g::Grid, i) = g[i], i+1

GLAbstraction.isa_gl_struct(x::Grid) = true
GLAbstraction.toglsltype_string(t::Grid{N,T}) where {N,T} = "uniform Grid$(N)D"
function GLAbstraction.gl_convert_struct(g::Grid{N, T}, uniform_name::Symbol) where {N,T}
    return Dict{Symbol, Any}(
        Symbol("$uniform_name.ref") => Vec{N, Float32}(map(x-> eltype(x)(x.ref), g.dims)),
        Symbol("$uniform_name.offset") => Vec{N, Float32}(map(x-> eltype(x)(x.offset), g.dims)),
        Symbol("$uniform_name._step") => Vec{N, Float32}(map(x-> step(x), g.dims)),
        Symbol("$uniform_name.dims") => Vec{N, Cint}(map(length, g.dims))
    )
end
function GLAbstraction.gl_convert_struct(g::Grid{1, T}, uniform_name::Symbol) where T
    x = g.dims[1]
    return Dict{Symbol, Any}(
        Symbol("$uniform_name.ref") => Float32(eltype(x)(x.ref)),
        Symbol("$uniform_name.offset") => Float32(eltype(x)(x.offset)),
        Symbol("$uniform_name._step") => Float32(step(x)),
        Symbol("$uniform_name.dims") => Cint(length(x))
    )
end
import Base: getindex, length, next, start, done



to_cpu_mem(x) = x
to_cpu_mem(x::GPUArray) = gpu_data(x)

const ScaleTypes = Union{Vector, Vec, AbstractFloat, Void, Grid}
const PositionTypes = Union{Vector, Point, AbstractFloat, Void, Grid}

mutable struct ScalarRepeat{T}
    scalar::T
end
Base.ndims(::ScalarRepeat) = 1
Base.getindex(s::ScalarRepeat, i...) = s.scalar
#should setindex! really be allowed? It will set the index for the whole row...
Base.setindex!(s::ScalarRepeat{T}, value, i...) where {T} = (s.scalar = T(value))
Base.eltype{T}(::ScalarRepeat{T}) = T

Base.start(::ScalarRepeat) = 1
Base.next(sr::ScalarRepeat, i) = sr.scalar, i+1
Base.done(sr::ScalarRepeat, i) = false

struct Instances{P,T,S,R}
    primitive::P
    translation::T
    scale::S
    rotation::R
end



function _Instances(position,px,py,pz, scale,sx,sy,sz, rotation, primitive)
    args = (position,px,py,pz, scale,sx,sy,sz, rotation, primitive)
    args = map(to_cpu_mem, args)
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

struct GridZRepeat{G, T, N} <: AbstractArray{Point{3, T}, N}
    grid::G
    z::Array{T, N}
end
Base.size(g::GridZRepeat) = size(g.z)
Base.size(g::GridZRepeat, i) = size(g.z, i)
Base.IndexStyle(::Type{<:GridZRepeat}) = Base.IndexLinear()

function Base.getindex(g::GridZRepeat{G, T}, i) where {G,T}
    pxy = g.grid[i]
    Point{3, T}(pxy[1], pxy[2], g.z[i])
end






function ArrayOrStructOfArray{T}(::Type{T}, array::Void, a, elements...)
    StructOfArrays(T, a, elements...)
end
function ArrayOrStructOfArray{T}(::Type{T}, array::StaticVector, a, elements...)
    StructOfArrays(T, a, elements...)
end
function ArrayOrStructOfArray{T}(::Type{T}, scalar::StaticVector, a::Void, elements::Void...)
    ScalarRepeat(transform_convert(T, scalar))
end
function ArrayOrStructOfArray{T1,T2}(::Type{T1}, array::Array{T2}, a::Void, elements::Void...)
    array
end
function ArrayOrStructOfArray{T1<:Point}(::Type{T1}, grid::Grid, x::Void, y::Void, z::Array)
    GridZRepeat(grid, z)
end
function ArrayOrStructOfArray{T1<:Point}(::Type{T1}, array::Grid, a::Void, elements::Void...)
    array
end
function ArrayOrStructOfArray{T}(::Type{T}, scalar::T)
    ScalarRepeat(scalar)
end
function ArrayOrStructOfArray{T}(::Type{T}, array::Array)
    array
end




struct TransformationIterator{T,S,R}
    translation::T
    scale::S
    rotation::R
end
function TransformationIterator(instances::Instances)
    TransformationIterator(
        instances.translation,
        instances.scale,
        instances.rotation
    )
end
function start(t::TransformationIterator)
    start(t.translation), start(t.scale), start(t.rotation)
end

function done(t::TransformationIterator, state)
    (done(t.translation, state[1]) ||
    done(t.scale, state[2]) ||
    done(t.rotation, state[3]))::Bool
end

import GeometryTypes: transform_convert

function next(t::TransformationIterator, state)
    _translation, st = next(t.translation, state[1])
    _scale, ss = next(t.scale, state[2])
    _rotation, sr = next(t.rotation, state[3])

    translation = Point3f0(transform_convert(Vec3f0, _translation))
    scale = Vec3f0(transform_convert(Point3f0, _scale))
    rotation = Vec3f0(transform_convert(Point3f0, _rotation))
    v,u = normalize(rotation), Vec3f0(0,0,1)
    # Unfortunately, we have to check for when u == -v, as u + v
    # in this case will be (0, 0, 0), which cannot be normalized.
    T = Float32
    local q::Quaternion{T}
    if (u == -v)
        # 180 degree rotation around any orthogonal vector
        other = (abs(dot(u, Vec{3, T}(1,0,0))) < 1.0) ? Vec{3, T}(1,0,0) : Vec{3, T}(0,1,0)
        q = Quaternions.qrotation(normalize(cross(u, other)), T(180))
    else
        half = normalize(u+v)
        vc = cross(u, half)
        q = Quaternions.Quaternion(dot(u, half), vc[1], vc[2], vc[3])
    end
    ((translation, scale, Mat4{T}(q)), (st, ss, sr))
end



struct Intensity{T <: AbstractFloat} <: FieldVector{1, T}
    i::T
end
@inline (I::Type{Intensity{T}}){T <: AbstractFloat}(i::Tuple) = I(i...)
@inline (I::Type{Intensity{T}}){T <: AbstractFloat}(i::Intensity) = I(i.i)
Intensity{T}(x::Color{Tc, 1}) where {T <: AbstractFloat, Tc} = Intensity{T}(gray(x))

const GLIntensity = Intensity{Float32}
export Intensity, GLIntensity


NOT(x) = !x

struct GLVisualizeShader <: AbstractLazyShader
    paths::Tuple
    kw_args::Dict{Symbol, Any}
    function GLVisualizeShader(paths::String...; view = Dict{String, String}(), kw_args...)
        # TODO properly check what extensions are available
        @static if !is_apple()
            view["GLSL_EXTENSIONS"] = "#extension GL_ARB_conservative_depth: enable"
            view["SUPPORTED_EXTENSIONS"] = "#define DETPH_LAYOUT"
        end
        args = Dict{Symbol, Any}(kw_args)
        args[:view] = view
        args[:fragdatalocation] = [(0, "fragment_color"), (1, "fragment_groupid")]
        new(map(x-> assetpath("shader", x), paths), args)
    end
end
