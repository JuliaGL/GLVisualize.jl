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
Base.length(p::Grid) = prod(size(p))
Base.size(p::Grid) = map(length, p.dims)
function Base.getindex{N,T}(p::Grid{N,T}, i)
    inds = ind2sub(size(p), i)
    Point{N, eltype(T)}(ntuple(Val{N}) do i
        p.dims[i][inds[i]]
    end)
end

Base.start(g::Grid) = 1
Base.done(g::Grid, i) = i > length(g)
Base.next(g::Grid, i) = g[i], i+1

GLAbstraction.isa_gl_struct(x::Grid) = true
GLAbstraction.toglsltype_string{N,T}(t::Grid{N,T}) = "uniform Grid$(N)D"
function GLAbstraction.gl_convert_struct{N,T}(g::Grid{N,T}, uniform_name::Symbol)
    return Dict{Symbol, Any}(
        symbol("$uniform_name.minimum") => Vec{N,Float32}(map(first, g.dims)),
        symbol("$uniform_name.maximum") => Vec{N,Float32}(map(last, g.dims)),
        symbol("$uniform_name.dims")    => Vec{N,Cint}(map(length, g.dims)),
        symbol("$uniform_name.multiplicator") => Vec{N,Float32}(map(x->1/x.divisor, g.dims)),
    )
end
function GLAbstraction.gl_convert_struct{T}(g::Grid{1,T}, uniform_name::Symbol)
    return Dict{Symbol, Any}(
        symbol("$uniform_name.minimum") => Float32(first(g.dims[1])),
        symbol("$uniform_name.maximum") => Float32(last(g.dims[1])),
        symbol("$uniform_name.dims")    => Cint(length(g.dims[1])),
        symbol("$uniform_name.multiplicator") => Float32(1/g.dims[1].divisor),


    )
end
import Base: getindex, length, next, start, done


iter_or_array(x) = repeated(x)
iter_or_array(x::Array) = x


to_cpu_mem(x) = x
to_cpu_mem(x::GPUArray) = gpu_data(x)

typealias ScaleTypes Union{Vector, Vec, AbstractFloat, Void, Grid}
typealias PositionTypes Union{Vector, Point, AbstractFloat, Void, Grid}


immutable Instances
    primitive
    translation
    scale
    rotation
end
immutable GridZRepeat{G,T,N} <: AbstractArray{Point{3,T}, N}
    grid::G
    z::Array{T, N}
end
Base.size(g::GridZRepeat) = size(g.z)
Base.size(g::GridZRepeat, i) = size(g.z, i)
Base.linearindexing{T<:GridZRepeat}(::Type{T}) = Base.LinearFast()
Base.getindex{G,T}(g::GridZRepeat{G,T}, i) = Point{3, T}(g.grid[i], g.z[i])


function ArrayOrStructOfArray{T}(::Type{T}, array::Void, a, elements...)
    StructOfArrays(T, a, elements...)
end
function ArrayOrStructOfArray{T}(::Type{T}, array::FixedVector, a, elements...)
    StructOfArrays(T, a, elements...)
end
function ArrayOrStructOfArray{T}(::Type{T}, scalar::FixedVector, a::Void, elements::Void...)
    ScalarRepeat(transformation_convert(T, scalar))
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

transformation_convert{T}(::Type{T}, scalar) = convert(T, scalar)
function transformation_convert{T1<:FixedVector,T2<:FixedVector}(
        ::Type{T1}, scalar::T2
    )
    T1(scalar)
end

function transformation_convert{T1,T2,N1,N2}(
        PT::Type{Point{N1, T1}}, scalar::FixedVector{N2,T2}
    )
    PT(scalar, ntuple(FixedSizeArrays.ConstFunctor(T1(0)), Val{N1-N2})...)
end
function transformation_convert{T1,T2,N1,N2}(
        VT::Type{Vec{N1, T1}}, scalar::FixedVector{N2, T2}
    )
    VT(scalar, ntuple(FixedSizeArrays.ConstFunctor(T1(1)), Val{N1-N2})...)
end

immutable TransformationIterator{T,S,R}
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
    start(t.translation),start(t.scale),start(t.rotation)
end
function done(t::TransformationIterator, state)
    done(t.translation, state[1]) ||
    done(t.scale, state[2]) ||
    done(t.rotation, state[3])
end
function next(t::TransformationIterator, state)
    _translation, st = next(t.translation, state[1])
    _scale, ss = next(t.scale, state[2])
    _rotation, sr = next(t.rotation, state[3])

    translation = transformation_convert(Point3f0, _translation)
    scale = transformation_convert(Vec3f0, _scale)
    rotation = transformation_convert(Vec3f0, _rotation)
    v,u = FixedSizeArrays.normalize(rotation), Vec3f0(0,0,1)
    # Unfortunately, we have to check for when u == -v, as u + v
    # in this case will be (0, 0, 0), which cannot be normalized.
    T = Float32
    if (u == -v)
        # 180 degree rotation around any orthogonal vector
        other = (abs(dot(u, Vec{3, T}(1,0,0))) < 1.0) ? Vec{3, T}(1,0,0) : Vec{3, T}(0,1,0)
        q = Quaternions.qrotation(FixedSizeArrays.normalize(cross(u, other)), T(180))
    else
        half = FixedSizeArrays.normalize(u+v)
        q = Quaternions.Quaternion(dot(u, half), cross(u, half)...)
    end
    (translation, scale, Mat{4,4,T}(q)), (st, ss, sr)
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
        view = filter(kv->kv[1]==:view, kw_args)
        if isempty(view)
            view = Dict{ASCIIString, ASCIIString}()
        else
            view = view[1][2]
        end
        view = merge(view, Dict(
            "GLSL_EXTENSIONS" => "#extension GL_ARB_conservative_depth: enable"
        ))
        paths = map(shader -> loadasset("shader", shader), paths)
        new(paths, vcat(kw_args, [
        	(:fragdatalocation, [(0, "fragment_color"), (1, "fragment_groupid")]),
    		(:updatewhile, ROOT_SCREEN.inputs[:window_open]),
    		(:update_interval, 1.0),
            (:view, view)
        ]))
    end
end
