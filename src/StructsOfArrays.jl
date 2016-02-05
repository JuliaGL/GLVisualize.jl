module StructsOfArrays
export StructOfArrays, ScalarRepeat

immutable StructOfArrays{T,N,U<:Tuple} <: AbstractArray{T,N}
    arrays::U
end

type ScalarRepeat{T}
    scalar::T
end
Base.ndims(::ScalarRepeat) = 1
Base.getindex(s::ScalarRepeat, i...) = s.scalar
#should setindex! really be allowed? It will set the index for the whole row...
Base.setindex!{T}(s::ScalarRepeat{T}, value, i...) = (s.scalar = T(value))
Base.eltype{T}(::ScalarRepeat{T}) = T

Base.start(::ScalarRepeat) = 1
Base.next(sr::ScalarRepeat, i) = sr.scalar, i+1
Base.done(sr::ScalarRepeat, i) = false


# since this is used in hot loops, and T.types[.] doesn't play well with compiler
# this needs to be a generated function
@generated function is_tuple_struct{T}(::Type{T})
    is_ts = length(T.types) == 1 && T.types[1] <: Tuple
    :($is_ts)
end
struct_eltypes{T}(struct::T) = struct_eltypes(T)
function struct_eltypes{T}(::Type{T})
    if is_tuple_struct(T) #special case tuple types (E.g. FixedSizeVectors)
        return eltypes = T.types[1].parameters
    else
        return eltypes = T.types
    end
end

make_iterable(x::AbstractArray) = x
make_iterable(x) = ScalarRepeat(x)

@generated function StructOfArrays{T}(::Type{T}, dim1::Integer, rest::Integer...)
    (!isleaftype(T) || T.mutable) && return :(throw(ArgumentError("can only create an StructOfArrays of leaf type immutables")))
    isempty(T.types) && return :(throw(ArgumentError("cannot create an StructOfArrays of an empty or bitstype")))
    dims = (dim1, rest...)
    N = length(dims)
    eltypes  = struct_eltypes(T)
    arrtuple = Tuple{[Array{eltypes[i],N} for i = 1:length(eltypes)]...}

    :(StructOfArrays{T,$N,$arrtuple}(
        ($([:(Array($(eltypes[i]), (dim1, rest...))) for i = 1:length(eltypes)]...),)
    ))
end
StructOfArrays(T::Type, dims::Tuple{Vararg{Integer}}) = StructOfArrays(T, dims...)

function StructOfArrays(T::Type, a, rest...)
    arrays = map(make_iterable, (a, rest...))
    N = ndims(arrays[1])
    eltypes = map(eltype, arrays)
    s_eltypes = struct_eltypes(T)
    any(ix->ix[1]!=ix[2], zip(eltypes,s_eltypes)) && throw(ArgumentError(
        "fieldtypes of $T must be equal to eltypes of arrays: $eltypes"
    ))
    any(x->ndims(x)!=N, arrays) && throw(ArgumentError(
        "cannot create an StructOfArrays from arrays with different ndims"
    ))
    arrtuple = Tuple{map(typeof, arrays)...}
    StructOfArrays{T, N, arrtuple}(arrays)
end

Base.linearindexing{T<:StructOfArrays}(::Type{T}) = Base.LinearFast()

@generated function Base.similar{T}(A::StructOfArrays, ::Type{T}, dims::Dims)
    if isbits(T) && length(T.types) > 1
        :(StructOfArrays(T, dims))
    else
        :(Array(T, dims))
    end
end

Base.convert{T,S,N}(::Type{StructOfArrays{T,N}}, A::AbstractArray{S,N}) =
    copy!(StructOfArrays(T, size(A)), A)
Base.convert{T,S,N}(::Type{StructOfArrays{T}}, A::AbstractArray{S,N}) =
    convert(StructOfArrays{T,N}, A)
Base.convert{T,N}(::Type{StructOfArrays}, A::AbstractArray{T,N}) =
    convert(StructOfArrays{T,N}, A)

function Base.size(A::StructOfArrays)
    for elem in A.arrays
        if isa(elem, AbstractArray)
            return size(elem)
        end
    end
    ()
end
Base.size(A::StructOfArrays, d) = size(A)[d]

@generated function Base.getindex{T}(A::StructOfArrays{T}, i::Integer...)
    n = length(struct_eltypes(T))
    Expr(:block, Expr(:meta, :inline),
         :($T($([:(A.arrays[$j][i...]) for j = 1:n]...)))
    )
end

function _getindex{T}(x::T, i)
    is_tuple_struct(T) ? x[i] : getfield(x, i)
end
@generated function Base.setindex!{T}(A::StructOfArrays{T}, x, i::Integer...)
    n = length(struct_eltypes(T))
    quote
        $(Expr(:meta, :inline))
        v = convert(T, x)
        $([:(A.arrays[$j][i...] = _getindex(v, $j)) for j = 1:n]...)
        x
    end
end
end # module
