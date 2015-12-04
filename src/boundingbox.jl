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

convert_position(x::GPUArray) = gpu_data(x)
convert_position(x) = x

convert_scale(x::GPUArray, _) = gpu_data(x)
convert_scale{N,T,X}(x::Vec{N,X}, ::Type{Vec{N, T}}) = Vec{N,T}(x)
convert_scale{T,X}(x::Vec{2,X},   ::Type{Vec{3, T}}) = Vec{3,T}(x, 1)
convert_scale{N,T,X}(x::Vec{N,X}, ::Type{Vec{2, T}}) = Vec{2,T}(x)
convert_scale{N,T}(x::Vec,        ::Type{HyperRectangle{N,T}}) = convert_scale(x, Vec{N,T})
convert_scale(x, z) = x

convert_bb(x::AABB) = x
convert_bb(x) = AABB{Float32}(x)
function call{T}(B::Type{AABB{T}}, positions, scale, primitive)
    p  = const_lift(convert_position, positions)
    bb = const_lift(convert_bb, primitive)
    const_lift(B, p, scale, bb)
end

function call{T, N1,N2}(B::Type{AABB{T}}, positions::Vector{Point{N1, T}}, scale::Vec{N2, T}, primitive_bb::AABB{T})
    primitive_scaled_min = minimum(primitive_bb) .* scale
    primitive_scaled_max = maximum(primitive_bb) .* scale
    pmax = max(primitive_scaled_min, primitive_scaled_max)
    pmin = min(primitive_scaled_min, primitive_scaled_max)
    main_bb = B(positions)
    B(minimum(main_bb) + pmin, maximum(main_bb) + pmax)
end
function call{T, R, N}(B::Type{AABB{T}}, grid::Grid{N, R}, scale::Void, primitive_bb::AABB{T})
    primitive_scaled_min = minimum(primitive_bb)
    primitive_scaled_max = maximum(primitive_bb)
    pmax = max(primitive_scaled_min, primitive_scaled_max)
    pmin = min(primitive_scaled_min, primitive_scaled_max)
    mainmin = Vec(Vec{N, Float32}(map(first, grid.dims)), 0f0)
    mainmax = Vec(Vec{N, Float32}(map(last, grid.dims)), 0f0)
    B(mainmin + pmin, mainmax + pmax)
end

function call{T, N}(B::Type{AABB{T}}, positions::Vector{Point{N, T}}, scale::Vector{Vec{N, T}}, primitive_bb::AABB{T})
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
    B(_min, _max)
end



particle_grid_bb{T}(min_xy::Vec{2,T}, max_xy::Vec{2,T}, minmax_z::Vec{2,T}) = AABB{T}(Vec(min_xy..., minmax_z[1]), Vec(max_xy..., minmax_z[2]))
