@enum Shape CIRCLE RECTANGLE ROUNDED_RECTANGLE DISTANCEFIELD TRIANGLE
@enum RaymarchAlgorithm IsoValue Absorption MaximumIntensityProjection
@enum CubeSides TOP BOTTOM FRONT BACK RIGHT LEFT

immutable Grid{N, T <: Range}
    dims::NTuple{N, T}
end
ndims{N,T}(::Grid{N,T}) = N

Grid(ranges::Range...) = Grid(ranges)
function Grid{N, T}(a::Array{T, N})
	s = Vec{N, Float32}(size(a))
	smax = maximum(s)
	s = s./smax
	Grid(ntuple(Val{N}) do i
		linspace(0, s[i], size(a, i))
	end)
end
Grid{T, N, X, N2}(a::Array{T, N}, ranges::NTuple{N2, NTuple{2, X}}) = error("
Dimension Missmatch. Supply ranges with $N values. Given: $ranges
")

function Grid{T, N, X}(a::Array{T, N}, ranges::NTuple{N, NTuple{2, X}})
	Grid(ntuple(Val{N}) do i
		linspace(first(ranges[i]), last(ranges[i]), size(a, i))
	end)
end
Base.length(p::Grid) = prod(map(length, p.dims))
Base.size(p::Grid) = map(length, p.dims)
function Base.getindex{N,T}(p::Grid{N,T}, i)
    inds = ind2sub(size(p), i)
    Point{N, eltype(T)}(ntuple(Val{N}) do i
        p.dims[i][inds[i]]
    end)
end
GLAbstraction.isa_gl_struct(x::Grid) = true
GLAbstraction.toglsltype_string{N,T}(t::Grid{N,T}) = "uniform Grid$(N)D"
function GLAbstraction.gl_convert_struct{N,T}(g::Grid{N,T}, uniform_name::Symbol)
    return Dict{Symbol, Any}(
        symbol("$uniform_name.minimum") => Vec{N,Float32}(map(first, g.dims)),
        symbol("$uniform_name.maximum") => Vec{N,Float32}(map(last, g.dims)),
        symbol("$uniform_name.dims")    => Vec{N,Cint}(map(length, g.dims)),
    )
end
function GLAbstraction.gl_convert_struct{T}(g::Grid{1,T}, uniform_name::Symbol)
    return Dict{Symbol, Any}(
        symbol("$uniform_name.minimum") => Float32(first(g.dims[1])),
        symbol("$uniform_name.maximum") => Float32(last(g.dims[1])),
        symbol("$uniform_name.dims")    => Cint(length(g.dims[1])),
    )
end
import Base: getindex, length, next, start, done


iter_or_array(x) = repeated(x)
iter_or_array(x::Array) = x

# An iterator over XYZ scale or positions, minimizing the type explosion for
# all the different types allowed for particle positions and scale
abstract XYZIterator

start(x::XYZIterator) = 1
done(x::XYZIterator, i) = length(x) < i
next(x::XYZIterator, i) = (x[i], i+1)
function length(x::XYZIterator)
    for name in fieldnames(x)
        isa(x.(name), Array) && return length(x.(name))
    end
    return typemax(Int) # if all scalar, we just return maximum length
end


to_cpu_mem(x) = x
to_cpu_mem(x::GPUArray) = gpu_data(x)


to3dims{T}(x::Vec{3,T}) = x
to3dims{T}(x::Vec{2,T}) = Vec{3,T}(x, 1)
to3dims{T}(x::Point{3,T}) = x
to3dims{T}(x::Point{2,T}) = Point{3,T}(x, 0)
function call{T <: XYZIterator}(::Type{T}, args...)
    cpu = map(to_cpu_mem, args)
    T{map(typeof, cpu)...}(cpu...)
end

typealias ScaleTypes Union{Vector, Vec, AbstractFloat, Void, Grid}
typealias PositionTypes Union{Vector, Point, AbstractFloat, Void, Grid}

immutable ScaleIterator{S<:ScaleTypes, SX<:ScaleTypes, SY<:ScaleTypes, SZ<:ScaleTypes} <: XYZIterator
    scale::S
    x::SX
    y::SY
    z::SZ
end

is_scalar{S, SX, SY, SZ}(::ScaleIterator{S, SX, SY, SZ}) = !any(x->isa(x,Vector), (S, SX, SY, SZ))

get_scale(x, i) = x
get_scale(x::Array, i) = x[i]
get_scale(x::Void, i) = 1
getindex{T<:Vector}(x::ScaleIterator{T, Void, Void, Void}, i)   = to3dims(get_scale(x.scale,i))
getindex{T<:Vec}(x::ScaleIterator{T, Void, Void, Void}, i)      = to3dims(x.scale)
getindex{X,Y,Z}(x::ScaleIterator{Void,X,Y,Z}, i)                = Vec(get_scale(x.x,i), get_scale(x.y,i), get_scale(x.z,i))
getindex{S<:Vec,X,Y,Z}(x::ScaleIterator{S,X,Y,Z}, i)            = Vec(get_scale(x.x,i), get_scale(x.y,i), get_scale(x.z,i))




immutable PositionIterator{P<:PositionTypes, PX<:PositionTypes, PY<:PositionTypes, PZ<:PositionTypes} <: XYZIterator
    position::P
    x::PX
    y::PY
    z::PZ
end

get_pos(x, i) = x
get_pos(x::Array, i) = x[i]
get_pos(x::Void, i) = 1
getindex{T<:Vector}(x::PositionIterator{T, Void, Void, Void}, i) = to3dims(get_pos(x.position,i))
getindex{T<:Point}(x::PositionIterator{T, Void, Void, Void}, i)  = to3dims(x.position)
getindex{S<:Point,X,Y,Z}(x::PositionIterator{S,X,Y,Z}, i)        = Point(get_pos(x.x,i), get_pos(x.y,i), get_pos(x.z,i))
getindex{X,Y,Z}(x::PositionIterator{Void,X,Y,Z}, i)              = Point(get_pos(x.x,i), get_pos(x.y,i), get_pos(x.z,i))

function getindex{T<:Grid{2}, Z}(x::PositionIterator{T,Void,Void,Z}, i)
    xy = x.position[i]
    Point{3, eltype(Z)}(xy, get_pos(x.z,i))
end



immutable Intensity{N, T} <: FixedVector{N, T}
	_::NTuple{N, T}
end
typealias GLIntensity Intensity{1, Float32}
export Intensity,GLIntensity

NOT(x) = !x
immutable GLVisualizeShader <: AbstractLazyShader
    paths  ::Tuple
    kw_args::Vector
    function GLVisualizeShader(paths...; kw_args...)
        paths = map(shader -> loadasset("shader", shader), paths)
        new(paths, vcat(kw_args, [
        	(:fragdatalocation, [(0, "fragment_color"), (1, "fragment_groupid")]),
    		(:updatewhile, ROOT_SCREEN.inputs[:window_open]),
    		(:update_interval, 1.0),
        ]))
    end
end
