function Base.delete!(dict::Dict, key, default)
    haskey(dict, key) && return pop!(dict, key)
    return default
end
function visualize_default{T <: Point3}(
        particles::Union(Texture{T, 1}, Vector{T}), 
        s::Style, kw_args=Dict()
    )
    color = delete!(kw_args, :color, RGBA(1f0, 0f0, 0f0, 1f0))
    color = texture_or_scalar(color)
    Dict(
        :primitive  => GLNormalMesh(Cube(Vec3(0), Vec3(1))),
        :color      => color,
        :scale      => Vec3(0.03)
    )
end

visualize{T}(value::Vector{Point3{T}}, s::Style, customizations=visualize_default(value, s)) = 
    visualize(texture_buffer(value), s, customizations)

function visualize{T}(signal::Signal{Vector{Point3{T}}}, s::Style, customizations=visualize_default(signal.value, s))
    tex = texture_buffer(signal.value)
    lift(update!, tex, signal)
    visualize(tex, s, customizations)
end
function visualize{T}(
        positions::Texture{Point3{T}, 1}, 
        s::Style, customizations=visualize_default(positions, s)
    )
    @materialize! primitive = customizations
    data = merge(Dict(
        :positions       => positions,
    ), collect_for_gl(primitive), customizations)

    program = TemplateProgram(
        File(shaderdir, "util.vert"), 
        File(shaderdir, "particles.vert"), 
        File(shaderdir, "standard.frag"), 
        attributes=data
    )
    instanced_renderobject(data, length(positions), program, Input(AABB(gpu_data(positions))))
end


