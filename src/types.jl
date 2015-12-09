typealias TOrSignal{T} Union{Signal{T}, T}

typealias ArrayOrSignal{T, N} TOrSignal{Array{T, N}}
typealias VecOrSignal{T} 	ArrayOrSignal{T, 1}
typealias MatOrSignal{T} 	ArrayOrSignal{T, 2}
typealias VolumeOrSignal{T} ArrayOrSignal{T, 3}

typealias ArrayTypes{T, N} Union{GPUArray{T, N}, ArrayOrSignal{T,N}}
typealias VecTypes{T} 		ArrayTypes{T, 1}
typealias MatTypes{T} 		ArrayTypes{T, 2}
typealias VolumeTypes{T} 	ArrayTypes{T, 3}



@enum Shape CIRCLE RECTANGLE ROUNDED_RECTANGLE DISTANCEFIELD TRIANGLE

immutable Grid{N, T <: Range}
    dims::NTuple{N, T}
end
ndims{N,T}(::Grid{N,T}) = N

Grid(ranges::Range...) = Grid(ranges)
function Grid{T, N}(a::Array{T, N})
	s = Vec{N, Float32}(size(a))
	smax = maximum(s)
	s = s./smax
	Grid(ntuple(Val{N}) do i
		linspace(0, s[i], size(a, i))
	end)
end

Base.length(p::Grid) = prod(map(length, p.dims))
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
call{T <: XYZIterator}(::Type{T}, p, x, y, z) =
    const_lift(T, map(to_cpu_mem, (p,x,y,z))...)

to3dims{T}(x::Vec{3,T}) = x
to3dims{T}(x::Vec{2,T}) = Vec{3,T}(x, 1)
to3dims{T}(x::Point{3,T}) = x
to3dims{T}(x::Point{2,T}) = Point{3,T}(x, 0)


immutable ScaleIterator{S, SX, SY, SZ} <: XYZIterator
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



immutable PositionIterator{P, PX, PY, PZ} <: XYZIterator
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



immutable Intensity{N, T} <: FixedVector{N, T}
	_::NTuple{N, T}
end
export Intensity


immutable GLVisualizeShader <: AbstractLazyShader
    paths  ::Tuple
    kw_args::Vector
    function GLVisualizeShader(paths...; kw_args...)
        paths = map(shader -> load(joinpath(shaderdir(), shader)), paths)
        new(paths, vcat(kw_args, [
        	(:fragdatalocation, [(0, "fragment_color"), (1, "fragment_groupid")]),
    		(:updatewhile, ROOT_SCREEN.inputs[:open]),
    		(:update_interval, 1.0),
        ]))
    end
end
