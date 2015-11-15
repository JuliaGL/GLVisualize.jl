function Base.delete!(dict::Dict, key, default)
    haskey(dict, key) && return pop!(dict, key)
    return default
end
function visualize_default{T <: Point}(particles::Union{Texture{T},Vector{T}}, s::Style, kw_args=Dict())
    color = delete!(kw_args, :color, RGBA(1f0, 0f0, 0f0, 1f0))
    color = texture_or_scalar(color)
    Dict(
        :primitive  => GLNormalMesh(Cube{Float32}(Vec3f0(0), Vec3f0(1))),
        :color      => color,
        :scale      => Vec3f0(0.03)
    )
end

visualize{T <: Point}(value::Vector{T}, s::Style, customizations=visualize_default(value, s)) = 
    visualize(texture_buffer(value), s, customizations)

function visualize{T <: Point}(signal::Signal{Vector{T}}, s::Style, customizations=visualize_default(signal.value, s))
    tex = texture_buffer(value(signal))
    preserve(const_lift(update!, tex, signal))
    visualize(tex, s, customizations)
end


Base.call{T, T2, T3}(::Type{AABB{T}}, positions::Texture{Point{3, T2}, 1}, scale::Texture{Vec{3, T3}, 1}, primitive_bb) = AABB{T}(gpu_data(positions), gpu_data(scale), primitive_bb)
Base.call{T, T2, T3}(::Type{AABB{T}}, positions::Texture{Point{3, T2}, 1}, scale::Vec{3, T3}, primitive_bb) = AABB{T}(gpu_data(positions), scale, primitive_bb)

function Base.call{T, T2, T3}(::Type{AABB{T}}, positions::Vector{Point{3, T2}}, scale::Vec{3, T3}, primitive_bb)
    primitive_scaled_min = minimum(primitive_bb) .* scale
    primitive_scaled_max = maximum(primitive_bb) .* scale
    pmax = max(primitive_scaled_min, primitive_scaled_max)
    pmin = min(primitive_scaled_min, primitive_scaled_max)
    main_bb = AABB{T}(positions)
    AABB{T}(minimum(main_bb) + pmin, maximum(main_bb) + pmax)
end
function Base.call{T, T2, T3}(::Type{AABB{T}}, positions::Vector{Point{3, T2}}, scale::Vector{Vec{3, T3}}, primitive_bb)
    _max = Vec{3, T}(typemin(T))
    _min = Vec{3, T}(typemax(T))
    for (p, s) in zip(positions, scale)
        p = Vec{3, T}(p) 
        s_min = Vec{3, T}(s) .* minimum(primitive_bb)
        s_max = Vec{3, T}(s) .* maximum(primitive_bb)
        s_min_r = min(s_min, s_max)
        s_max_r = max(s_min, s_max)
        _min = min(_min, p + s_min_r)
        _max = max(_max, p + s_max_r)
    end
    AABB{T}(_min, _max)
end

function visualize{T<:Point}(
        positions::Texture{T, 1}, 
        s::Style, customizations=visualize_default(positions, s)
    )
    @materialize! primitive = customizations
    @materialize scale = customizations
    data = merge(Dict(
        :positions       => positions,
    ), collect_for_gl(primitive), customizations)
    assemble_instanced(
        positions, data,
        "util.vert", "particles.vert", "standard.frag",
        boundingbox=Signal(AABB{Float32}(positions, scale, AABB{Float32}(vertices(primitive))))
    )
end


