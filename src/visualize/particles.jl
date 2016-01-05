function Base.delete!(dict::Dict, key, default)
    haskey(dict, key) && return pop!(dict, key)
    return default
end
function visualize_default{T <: Point}(particles::Union{Texture{T},Vector{T}}, s::Style, kw_args=Dict())
    color = delete!(kw_args, :color, default(RGBA, s))
    color = texture_or_scalar(color)
    Dict(
        :primitive  => GLNormalMesh(AABB{Float32}(Vec3f0(0), Vec3f0(1))),
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


