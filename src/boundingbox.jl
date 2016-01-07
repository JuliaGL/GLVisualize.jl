AbsoluteRectangle{N,T}(mini::Vec{N,T}, maxi::Vec{N,T}) = HyperRectangle{N,T}(mini, maxi-mini)

call(::Type{AABB}, a) = AABB{Float32}(a)
function call{T}(B::Type{AABB{T}}, a::Pyramid)
    w,h = a.width/T(2), a.length
    m = Vec{3,T}(a.middle)
    B(m-Vec{3,T}(w,w,0), m+Vec{3,T}(w, w, h))
end
call{T}(B::Type{AABB{T}}, a::Cube) = B(origin(a), widths(a))
call{T}(B::Type{AABB{T}}, a::AbstractMesh) = B(vertices(a))
call{T}(B::Type{AABB{T}}, a::NativeMesh) = B(gpu_data(a.data[:vertices]))


function call{T}(B::Type{AABB{T}}, positions::PositionIterator, scale::ScaleIterator, primitive::AABB{T})
    _max = Vec{3, T}(typemin(T))
    _min = Vec{3, T}(typemax(T))
    for (p, s) in zip(positions, scale)
        p = Vec{3, T}(p)
        s_min   = Vec{3, T}(s) .* minimum(primitive)
        s_max   = Vec{3, T}(s) .* maximum(primitive)
        s_min_r = min(s_min, s_max)
        s_max_r = max(s_min, s_max)
        _min    = min(_min, p + s_min_r)
        _max    = max(_max, p + s_max_r)
    end
    AbsoluteRectangle(_min, _max)
end

function Base.maximum(scale::ScaleIterator)
    if is_scalar(scale)
        return scale[1]
    else
        _max = Vec{3, T}(typemin(T))
        for elem in scale
            _max = max(elem, _max)
        end
        return _max
    end
end
function Base.minimum(scale::ScaleIterator)
    if is_scalar(scale)
        return scale[1]
    else
        _min = Vec{3, T}(typemax(T))
        for elem in scale
            _min = min(elem, _min)
        end
        return _min
    end
end

function call{T, P<:Grid}(B::Type{AABB{T}}, positions::PositionIterator{P}, scale::ScaleIterator, primitive::AABB{T})
    grid = positions.position
    N    = ndims(grid)
    smin = minimum(scale)
    smax = maximum(scale)
    pmin = minimum(primitive) .* smin
    pmax = maximum(primitive) .* smax
    _min = Vec3f0(map(first, grid.dims)..., ntuple(x->0f0, 3-N)...)
    _max = Vec3f0(map(last,  grid.dims)..., ntuple(x->0f0, 3-N)...)
    return AbsoluteRectangle(_min + pmin, _max + pmax)
end
