
function default_boundingbox(main, model)
    main == nothing && return Signal(AABB{Float32}(Vec3f0(0), Vec3f0(1)))
    const_lift(*, model, AABB{Float32}(main))
end

# As long as we don't calculate bounding boxes on the gpu, this needs to do:
Base.minimum(t::Texture) = minimum(gpu_data(t))
Base.maximum(t::Texture) = maximum(gpu_data(t))

call{T}(B::Type{AABB{T}}, a::Cube) = B(a.origin, a.origin+a.width)

call(::Type{AABB}, a) = AABB{Float32}(a)
call{T}(::Type{AABB{T}}, a::GPUArray) = AABB{T}(gpu_data(a))

call{T}(B::Type{AABB{T}}, a::AbstractMesh) = B(vertices(a))
call{T}(B::Type{AABB{T}}, a::NativeMesh) = B(gpu_data(a.data[:vertices]))
call{T}(B::Type{AABB{T}}, a::GPUArray) = B(gpu_data(a))




call{T, P<:Point}(B::Type{AABB{T}}, positions::GPUArray{P}, scale::GPUArray, primitive_bb) = B(gpu_data(positions), gpu_data(scale), primitive_bb)
call{T, P<:Point}(B::Type{AABB{T}}, positions::GPUArray{P}, scale::Vec3f0, primitive_bb) = B(gpu_data(positions), scale, primitive_bb)
call{T, P<:Point}(B::Type{AABB{T}}, positions::GPUArray{P}, scale::Void, primitive_bb) = B(gpu_data(positions), Vec3f0(1), primitive_bb)
call{T, P<:Point}(B::Type{AABB{T}}, positions::VecOrSignal{P}, scale::Void, primitive_bb) = B(value(positions), Vec3f0(1), primitive_bb)


function call{T, T2, N}(B::Type{AABB{T}}, positions::VecOrSignal{Point{N, T2}}, scale, primitive)
    bb = B(primitive)
    B(value(positions), value(scale), bb)
end
function call{T, T2, T3, N}(B::Type{AABB{T}}, p::VecOrSignal{Point{N, T2}}, scale::Vec{N, T3}, bb)
    primitive_bb = B(bb)
    positions = value(p)
    primitive_scaled_min = minimum(primitive_bb) .* scale
    primitive_scaled_max = maximum(primitive_bb) .* scale
    pmax = max(primitive_scaled_min, primitive_scaled_max)
    pmin = min(primitive_scaled_min, primitive_scaled_max)
    main_bb = AABB{T}(positions)
    mini,maxi = minimum(main_bb) + pmin, maximum(main_bb) + pmax
    AABB{T}(mini, maxi)
end

function call{T, T2, T3, N}(B::Type{AABB{T}}, p::VecOrSignal{Point{N, T2}}, s::VecOrSignal{Vec{N, T3}}, bb)
    primitive_bb = B(bb)
    positions, scale = value(p), value(s)
    _max = Vec{N, T}(typemin(T))
    _min = Vec{N, T}(typemax(T))
    for (p, s) in zip(positions, scale)
        p = Vec{N, T}(p)
        s_min = Vec{N, T}(s) .* minimum(primitive_bb)
        s_max = Vec{N, T}(s) .* maximum(primitive_bb)
        s_min_r = min(s_min, s_max)
        s_max_r = max(s_min, s_max)
        _min = min(_min, p + s_min_r)
        _max = max(_max, p + s_max_r)
    end
    AABB{T}(_min, _max)
end
particle_grid_bb{T}(min_xy::Vec{2,T}, max_xy::Vec{2,T}, minmax_z::Vec{2,T}) = AABB{T}(Vec(min_xy..., minmax_z[1]), Vec(max_xy..., minmax_z[2]))
